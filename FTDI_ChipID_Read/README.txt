FTChipID

This is the basic interface to obtain the Chip ID of a 232R device.

The Dll is required to obtain the 232R unique chip ID. This includes .net applications 
(the .net interface dll requires this dll).


The API is very simple and should be relatively easy to grasp when using the sample applications.

FTID_GetNumDevices - returns the number of 232R devices on the bus
FTID_GetDeviceSerialNumber - Given a device index return the serial number
FTID_GetDeviceDescription - as above with description
FTID_GetDeviceLocationID - as above with location ID
FTID_GetDeviceChipID - returns the unique Chip ID of the device
FTID_GetChipIDFromHandle - must use a valid D2XX device handle.
FTID_GetDllVersion - get the dll version
FTID_GetErrorCodeString - get the English translation of the error code.

Samples are provided for a Console, MFC, Win32, Delphi, C# and VB.net. Both the .net samples require an additional interface assembly which is provided in the samples.

Care must be taken when placing dlls in your system for the samples to work properly.
