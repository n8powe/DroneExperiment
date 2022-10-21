import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd

df = pd.read_csv('droneOrientationDataset120SecondCrossCorrelations_leaveOut.txt', sep=',')

#print (df.head())

collisionIndicies = df.index[df['numberCollisions']>1].tolist()
#print (collisionIndicies)
df = df.drop(collisionIndicies)

y = df['rTH_GH']
x = df['lagTH_GH']
density_param = {"density": True}

fig, ax = plt.subplots(2, 2, gridspec_kw={'width_ratios': [3, 1], 'height_ratios':[1,3]})
fig.delaxes(ax[0,1])
ax[1, 0].hist2d(x/60, y, bins=(30, 30), cmap=plt.cm.Reds)
ax[1, 0].scatter(0.22, 0.83, s=250, marker='*', color='c')
ax[1, 0].set_xlabel("Lag (Sec.)", fontsize=20)
ax[1, 0].set_ylabel("r", fontsize=20)


ax[1,1].hist(y, bins=30, orientation=u'horizontal')
ax[1,1].axes.yaxis.set_visible(False)
ax[1, 1].set_xlabel("Counts", fontsize=20)

ax[0, 0].hist(x/60, bins=30)
ax[0,0].axes.xaxis.set_visible(False)
ax[0, 0].set_ylabel("Counts", fontsize=20)

plt.subplots_adjust(wspace=0.015, hspace=0.015)
plt.setp(ax[1, 0].get_xticklabels(), Fontsize=14)
plt.setp(ax[1, 0].get_yticklabels(), Fontsize=14)
plt.setp(ax[0,0].get_yticklabels(), Fontsize=14)
plt.setp(ax[1, 1].get_xticklabels(), Fontsize=14)

plt.suptitle("Cross-correlation: gaze and thrust angles", fontsize=24)

plt.show()






#y = df['rTH_CH']
#x = df['lagTH_CH']

#fig, ax = plt.subplots(2, 2, gridspec_kw={'width_ratios': [3, 1], 'height_ratios':[1,3]})
#fig.delaxes(ax[0,1])
#ax[1, 0].hist2d(x/60, y, bins=(30, 30), cmap=plt.cm.Reds)
#ax[1, 0].scatter(0.043, 0.91, s=200, marker='*')

#ax[1,1].hist(y, bins=30, orientation=u'horizontal')

#ax[0, 0].hist(x/60, bins=30)

#plt.show()
