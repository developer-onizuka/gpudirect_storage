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

#define INIT_BUFSIZE 4096
#define TESTFILE "/mnt/test"

__global__ void hello(char *str) {
	printf("Hello World!\n");
	printf("buf: %s\n", str);
}

__global__ void strrev(char *str) {
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
}

int main(int argc, char *argv[])
{
	int fd;
	int ret;
	char *system_buf;
	char *gpumem_buf;
	long buf_size = INIT_BUFSIZE;
	system_buf = (char*)malloc(buf_size);
	cudaMalloc(&gpumem_buf, buf_size);
        off_t file_offset = 0;
        off_t mem_offset = 0;
	CUfileDescr_t cf_desc; 
	CUfileHandle_t cf_handle;

	cuFileDriverOpen();
	fd = open(argv[1], O_RDWR | O_DIRECT, 0664);

	cf_desc.handle.fd = fd;
	cf_desc.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD;

	cuFileHandleRegister(&cf_handle, &cf_desc);
	cuFileBufRegister((char*)gpumem_buf, buf_size, 0);

	ret = cuFileRead(cf_handle, (char*)gpumem_buf, buf_size, file_offset, mem_offset);
	if (ret < 0) {
		printf("cuFileRead failed : %d", ret); 
	}

	/*
	hello<<<1,1>>>(gpumem_buf);
	*/
	strrev<<<1,1>>>(gpumem_buf);

	/*
	ret = cuFileWrite(cf_handle, (char*)gpumem_buf, buf_size, file_offset, mem_offset);
	if (ret < 0) {
		printf("cuFileWrite failed : %d", ret); 
	}
	*/

	cudaMemcpy(system_buf, gpumem_buf, buf_size, cudaMemcpyDeviceToHost);
	printf("%s: %s\n", TESTFILE, system_buf);

	cuFileBufDeregister((char*)gpumem_buf);

	cudaFree(gpumem_buf);
	free(system_buf);

	close(fd);
	cuFileDriverClose();
}
