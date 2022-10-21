import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

posData = pd.read_csv('stackedDataWithThrustAngle.txt', sep=',', float_precision = None)

hoopData = pd.read_csv('obstacle_dataFixed.txt', sep='\t', float_precision = None)

zero_crossings = np.where(np.diff(np.sign(posData["ThrustAngle"])))[0]

#print (hoopData)

above_35 = posData[posData["ThrustAngle"] > 50]

#posData = posData[posData['Gaze_Location(x)'] != 0]
#plt.scatter(above_35['Position(x)'], above_35['Position(z)'], s=0.5, alpha=0.005, c=above_35.ThrustAngle, cmap='seismic')
#plt.scatter(hoopData['ObjectName'], hoopData['Position(y)'], alpha=0.3)
#plt.show()

PathOnly = posData[posData['Condition'] == "/PathOnly/"]
zero_crossings = np.where(np.diff(np.sign(PathOnly["ThrustAngle"])))[0]




HoopOnly = posData[posData['Condition'] == "/HoopOnly/"]

PathAndHoops = posData[posData['Condition'] == "/PathAndHoops/"]

fig, (ax1, ax2, ax3) = plt.subplots(1, 3)


#posData = posData[np.isfinite(posData['RE_Gaze_Pos(z)'])]
sns.set_style("white")
#sns.kdeplot(posData['Position(x)'][zero_crossings], posData['Position(z)'][zero_crossings], cmap="Reds", shade=True,thresh=1)
ax1.hist2d(PathOnly['Position(x)'][zero_crossings], PathOnly['Position(z)'][zero_crossings], bins=(200, 200), cmap=plt.cm.Reds)
ax1.scatter(hoopData['ObjectName'], hoopData['Position(y)'], s=7, alpha=0.6)
plt.show()

print (posData['RE_Gaze_Pos(x)'])


z = posData['RE_Gaze_Pos(z)']
z = z[z!=0]
x = posData['RE_Gaze_Pos(x)']
x = x[x!=0]
plt.hist2d(x, z, bins=(150, 150), cmap=plt.cm.Reds)
plt.scatter(hoopData['ObjectName'], hoopData['Position(y)'], s=7, alpha=0.6)
plt.show()
