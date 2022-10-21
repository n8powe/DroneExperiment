
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
import seaborn as sns
import scipy.stats as stats

df = pd.read_csv('stackedDataWithThrustAngle.txt', sep=',')

sub1df = df[df['Subject']=='P_220207122313_Nate']
