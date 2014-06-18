import PyDTCM
import gdal
import matplotlib.pyplot as plt

# Read the raster image as an array
testImage='L1 0245 B1 Clipped.tif'
dataA=gdal.Open(testImage)
band=dataA.GetRasterBand(1).ReadAsArray()

# Compute the cloud mask
mask = PyDTCM.dtcm(band, 15, 30, 'REF')
maskplot = plt.imshow(mask)
plt.axis('off')
plt.show()