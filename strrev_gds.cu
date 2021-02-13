#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <cuda.h>
#include <cuda_runtime.h>

#include "cufile.h"

#define KB(x) ((x)*1024L)
#define TESTFILE "/mnt/test"

__global__ void hello(char *str) {
	printf("Hello World!\n");
	printf("buf: %s\n", str);
}

__global__ void strrev(char *str, int *len) {
	int size = 0;
	while (str[size] != '\0') {
		size++;
	}
	for(int i=0;i<size/2;++i) {
		char t = str[i];
		str[i] = str[size-1-i];
		str[size-1-i] = t;
	}
	/*
	printf("buf: %s\n", str);
	printf("size: %d\n", size);
	*/
	*len = size;
}

int main(int argc, char *argv[])
{
	int fd;
	int ret;
	int *sys_len;
	int *gpu_len;
	char *system_buf;
	char *gpumem_buf;
	system_buf = (char*)malloc(KB(4));
	sys_len = (int*)malloc(KB(1));
	cudaMalloc(&gpumem_buf, KB(4));
	cudaMalloc(&gpu_len, KB(1));
        off_t file_offset = 0;
        off_t mem_offset = 0;
	CUfileDescr_t cf_desc; 
	CUfileHandle_t cf_handle;

	cuFileDriverOpen();
	fd = open(argv[1], O_RDWR | O_DIRECT);

	cf_desc.handle.fd = fd;
	cf_desc.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD;

	cuFileHandleRegister(&cf_handle, &cf_desc);
	cuFileBufRegister((char*)gpumem_buf, KB(4), 0);

	ret = cuFileRead(cf_handle, (char*)gpumem_buf, KB(4), file_offset, mem_offset);
	if (ret < 0) {
		printf("cuFileRead failed : %d", ret); 
	}

	/*
	hello<<<1,1>>>(gpumem_buf);
	*/
	strrev<<<1,1>>>(gpumem_buf, gpu_len);

	cudaMemcpy(sys_len, gpu_len, KB(1), cudaMemcpyDeviceToHost);
	printf("sys_len : %d\n", *sys_len); 
	ret = cuFileWrite(cf_handle, (char*)gpumem_buf, *sys_len, file_offset, mem_offset);
	if (ret < 0) {
		printf("cuFileWrite failed : %d", ret); 
	}

	cudaMemcpy(system_buf, gpumem_buf, KB(4), cudaMemcpyDeviceToHost);
	printf("%s\n", system_buf);
	printf("See also %s\n", argv[1]);

	cuFileBufDeregister((char*)gpumem_buf);

	cudaFree(gpumem_buf);
	cudaFree(gpu_len);
	free(system_buf);
	free(sys_len);

	close(fd);
	cuFileDriverClose();
}
