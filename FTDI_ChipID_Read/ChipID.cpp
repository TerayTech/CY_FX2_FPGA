// ChipID.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <windows.h>
#include <stdio.h>
#include "ftd2xx.h"
#include "FTChipID.h"

int main(int argc, char* argv[])
{
	char Version[100];
	unsigned long NumDevices = 0, LocID = 0, ChipID = 0;
	char SerialNumber[256], Description[256], ErrorMessage[256];
	FTID_STATUS dStatus;
	FT_HANDLE ftHandle;
	FT_STATUS ftStatus;
	DWORD iNumDevs;
	
	FTID_GetDllVersion(Version, 100);

	printf("Dll Version = %s\n\n", Version);
	
	dStatus = FTID_GetNumDevices(&NumDevices);
	//printf("%c\n\n",dStatus);
	//dStatus = FTID_GetDeviceSerialNumber(1, SerialNumber, 256);
	//if (dStatus == FTID_SUCCESS) {
	//	printf("\tSerial Number: %s\n", SerialNumber);
	//}
	//dStatus = FTID_GetDeviceChipID(0, &ChipID);
	//if (dStatus == FTID_SUCCESS) {
	//	printf("\tChip ID: 0x%08lX\n", ChipID);
	//}

	if((dStatus == FTID_SUCCESS) && 1) {

		printf("Number of 232R devices = %ld\n\n", NumDevices);

		for(int i = 0; i < (int)NumDevices; i++) {

			printf("Device %d\n", i);

			dStatus = FTID_GetDeviceSerialNumber(i, SerialNumber, 256);
			if(dStatus == FTID_SUCCESS) {
				printf("\tSerial Number: %s\n", SerialNumber);
			}

			dStatus = FTID_GetDeviceDescription(i, Description, 256);
			if(dStatus == FTID_SUCCESS) {
				printf("\tDescription: %s\n", Description);
			}

			dStatus = FTID_GetDeviceLocationID(i, &LocID);
			if(dStatus == FTID_SUCCESS) {
				printf("\tLocation ID: 0x%08lX\n", LocID);
			}

			dStatus = FTID_GetDeviceChipID(i, &ChipID);
			if(dStatus == FTID_SUCCESS) {
				printf("\tChip ID in DEC: %d\n", ChipID);
				printf("\tChip ID in HEX 0x%08lX\n", ChipID);
			}
			printf("\n");
		}
	}

	if(dStatus != FTID_SUCCESS) {
		FTID_GetErrorCodeString("EN", dStatus, ErrorMessage, 256);
		printf(ErrorMessage);
	}

	printf("Get Chip IDs using handle\n");

	FT_DEVICE_LIST_INFO_NODE *devInfo;

	//
	// create the device information list
	//
	ftStatus = FT_CreateDeviceInfoList(&iNumDevs);
	if (ftStatus == FT_OK) {
	   printf("%d FTDI devices connected\n",iNumDevs);
	}

	//
	// allocate storage for list based on numDevs
	//
	devInfo = (FT_DEVICE_LIST_INFO_NODE*)malloc(sizeof(FT_DEVICE_LIST_INFO_NODE)*iNumDevs);

	//
	// get the device information list
	//
	ftStatus = FT_GetDeviceInfoList(devInfo, &iNumDevs);
	if (ftStatus == FT_OK) {
		for (int i = 0; i < iNumDevs; i++) { 
			if(devInfo[i].Type == FT_DEVICE_232R) {
				FT_Open(i, &ftHandle);
				dStatus = FTID_GetChipIDFromHandle(ftHandle, &ChipID);
				if(dStatus == FTID_SUCCESS) {
					printf("\tChip ID: 0x%08lX\n", ChipID);
				}
				FT_Close(ftHandle);
			}
		}
	} 	

	printf("Press return to exit\n");
	getchar();

	return 0;
}
