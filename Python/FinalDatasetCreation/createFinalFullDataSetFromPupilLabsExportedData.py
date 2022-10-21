import json
import pandas as pd
import numpy as np
from copy import deepcopy
import os

def long_display():
  pd.set_option('display.max_rows', 40)

def pretty_display():
  pd.set_option('display.float_format', lambda x: f'{x:,.0f}')
  np.set_printoptions(suppress= True, precision=None, floatmode=None)
def reset_display():
  pd.reset_option('^display.', silent=True)
  np.set_printoptions(suppress= False)

outputFolder = 'Output_positionFiles/'

if os.path.isdir(outputFolder):
    pass
else:
    os.mkdir(outputFolder)

fileNames = os.listdir()

for myfile in fileNames:
    if myfile.endswith('.txt'):
        path_to_original_data = myfile
    elif myfile.endswith('.csv'):
        path_to_gaze_data = myfile
    elif myfile.endswith('.json'):
        path_to_json = myfile


#path_to_json = "info.player.json"
#path_to_gaze_data = "gaze_positions.csv"
#path_to_original_data = "drone_capture_P_210928152127_40_1_GatedPath.txt"
output_filename = outputFolder + 'final_positionfile_' + path_to_original_data


with open(path_to_json) as f:
    data = json.load(f)

epochTime = data["start_time_system_s"]
epochTime

with pd.option_context('display.precision', 20):
  gaze_data = pd.read_csv(path_to_gaze_data, sep=',', float_precision = None)

i_len = len(gaze_data)
gaze_data = gaze_data[gaze_data['confidence'] != 0]
gaze_data.reset_index(inplace=True)
f_len = len(gaze_data)
gazeTimeData = gaze_data['gaze_timestamp']
numTimes = len(gazeTimeData)

unixTimeConversion = np.ones([numTimes])
unixTimeConversion[0] = epochTime

for i in range(1, numTimes):
  unixTimeConversion[i] = epochTime + (gazeTimeData[i] - gazeTimeData[0])
  #print(unixTimeConversion[i])

gaze_data["UnixTime_Converted"] = np.float64(unixTimeConversion) * 1000


#Sort Dataframe by pupil timestamp
gaze_data.sort_values(by=['gaze_timestamp'], inplace=True, ascending=True, ignore_index=True)
gaze_data.drop(labels=['base_data', 'world_index', 'index'], axis = 1) #Drop useless data for faster processing

with pd.option_context('display.precision', 20):
  original_data = pd.read_csv(path_to_original_data, sep='\t', float_precision = None)


gaze_data.loc[:, "UnixTime_Converted"]
original_timestamps = original_data.loc[:, "Timestamp"].to_list()

so = sorted(original_timestamps)
for val in range(len(original_timestamps)):
  if original_timestamps[val] == so[val]:
    continue
  else:
    print("Sorting is fucked")
    break


inds = np.ones([numTimes])
unis = np.ones([numTimes], dtype=np.int64) #Dtype here is important. Timestamps are huge numbers
last_original_index = 0
for index, row in gaze_data.iterrows():

  last_difference = 9999999999999
  for ind in range(last_original_index, len(original_timestamps)):

    diff = abs(original_timestamps[ind] - row['UnixTime_Converted'])
    #print(f"Gaze {index} Try Unix {ind}: {row['UnixTime_Converted']}  - {original_timestamps[ind]} = {diff}")
    if diff <= last_difference:
      last_difference = diff
      last_original_index = ind
    else:
      break
  best_timestamp = original_timestamps[last_original_index]
  inds[index] = last_original_index
  unis[index] = best_timestamp

  #best_timestamp = min(original_timestamps, key=lambda x: abs(x - row['UnixTime_Converted']))
  #print(f"Index {index}: {row['UnixTime_Converted']}'s best fit is {best_timestamp}")
  #best_row = original_data.loc[original_data['Timestamp'] == best_timestamp].iloc[0]

  #best_row = original_data.iloc[last_original_index]
  #if len(best_row) > 25:
    #print(f"Index {index}: found len == {len(best_row)}")

  #for c in original_data.columns:
    #row[c] = best_row[c]
  #gaze_data.iloc[index][c] = row

gaze_data['Nearest_Unix'] = unis
gaze_data['Nearest_Index'] = inds #Drop this later


#Create a new dataframe with averaged values from each row
#It's row count should equal the original data
#downscaled_gaze_data = DataFrame()
CONFIDENCE_THRESHOLD = 0.0
invalid_left = 0
invalid_right = 0
both_invalid = 0
independently_averaged_columns_left = ["confidence","eye_center0_3d_x","eye_center0_3d_y","eye_center0_3d_z", "gaze_normal0_x", "gaze_normal0_y", "gaze_normal0_z"]
independently_averaged_columns_right = ["confidence","eye_center1_3d_x","eye_center1_3d_y","eye_center1_3d_z", "gaze_normal1_x", "gaze_normal1_y", "gaze_normal1_z"]
remaining_average_exceptions = ["eye_center0_3d_x","eye_center0_3d_y","eye_center0_3d_z", "gaze_normal0_x", "gaze_normal0_y", "gaze_normal0_z", "eye_center1_3d_x","eye_center1_3d_y","eye_center1_3d_z", "gaze_normal1_x", "gaze_normal1_y", "gaze_normal1_z"]
Remaining_columns = [i for i in gaze_data.columns if i not in remaining_average_exceptions]
conf = []
i = 0
mean_groups = []
grouped = gaze_data.groupby(['Nearest_Index'])
print(f"Grouped Length:{len(grouped)}")
for name, group in grouped:

  #Collect the indecies and once itterows finishes, we run averaging on that list for left and right
  left_indicies = []
  right_indicies = []
  remainder_indicies = []
  group.reset_index(inplace=True)
  for index, row in group.iterrows():
    if row['confidence'] >= CONFIDENCE_THRESHOLD:
      remainder_indicies.append(index)
      left_eye_valid = not np.isnan(row['gaze_normal0_x'])
      right_eye_valid = not np.isnan(row['gaze_normal1_x'])

      if left_eye_valid and right_eye_valid:
        left_indicies.append(index)
        right_indicies.append(index)
      elif left_eye_valid:
        invalid_right += 1
        conf.append(row['confidence'])
        left_indicies.append(index)
      elif right_eye_valid:
        invalid_left += 1
        conf.append(row['confidence'])
        right_indicies.append(index)
      else:
        both_invalid += 1

  #Compute Averaging for group
  left_group = group.iloc[left_indicies, [group.columns.get_loc(c) for c in independently_averaged_columns_left]].mean()
  right_group = group.iloc[right_indicies, [group.columns.get_loc(c) for c in independently_averaged_columns_right]].mean()
  remainder_group = group.iloc[remainder_indicies, [group.columns.get_loc(c) for c in Remaining_columns]].mean()

  left_group.rename({"confidence" : "confidence0"}, inplace=True)
  right_group.rename({"confidence" : "confidence1"},inplace=True)
  remainder_group.rename({"confidence" : "average_confidence"},inplace=True)
  final_row = pd.concat([remainder_group, left_group, right_group], axis=0)
  if i > 10 and i < 20:
    print(left_indicies, remainder_indicies, sep="\t")
    #display(group.iloc[left_indicies, [group.columns.get_loc(c) for c in independently_averaged_columns_left]])
  mean_groups.append(final_row)
  i += 1

downscaled_gaze_data = pd.concat(mean_groups, axis=1)
downscaled_gaze_data = downscaled_gaze_data.transpose()
downscaled_gaze_data.drop(labels='index', axis=1)

final_data = deepcopy(original_data)
new_cols = list(downscaled_gaze_data.columns)
new_cols.remove('index')
new_cols.remove('Nearest_Index')
final_data[new_cols] = pd.DataFrame([[np.nan] * len(new_cols)], index=final_data.index)

indicies = list(downscaled_gaze_data['Nearest_Index'])



for v in range(len(indicies)):
  indicies[v] = int(indicies[v])
print(final_data.index[indicies])
final_data.loc[final_data.index[indicies], new_cols] = downscaled_gaze_data[new_cols]

for index, row in downscaled_gaze_data.iterrows():
  final_row = int(row['Nearest_Index'])
  final_data.loc[final_data.index[final_row], new_cols] = row[new_cols]

final_data.drop(labels=['Nearest_Unix'], axis=1)


final_data.to_csv(output_filename)
