import json
import pandas as pd
import numpy as np
from copy import deepcopy
import os


def removeTheDuplicatePositionData(posData):
    trimmedDf = 0

    indicesToRemove = []
    nRows = posData.shape[0]

    for i in range(1,nRows):
        currX = posData['Position(x)'][i]
        currY = posData['Position(y)'][i]
        currZ = posData['Position(z)'][i]
        currOx = posData['Orientation(x)'][i]
        currOy = posData['Orientation(y)'][i]
        currOz = posData['Orientation(z)'][i]

        prevX = posData['Position(x)'][i-1]
        prevY = posData['Position(y)'][i-1]
        prevZ = posData['Position(z)'][i-1]
        prevOx = posData['Orientation(x)'][i-1]
        prevOy = posData['Orientation(y)'][i-1]
        prevOz = posData['Orientation(z)'][i-1]

        currData = (currX, currY, currZ, currOx, currOy, currOz)
        prevData = (prevX, prevY, prevZ, prevOx, prevOy, prevOz)

        if currData == prevData:
            indicesToRemove.append(i)


    trimmedDf = posData.drop(indicesToRemove)


    return len(indicesToRemove), trimmedDf


folderToParse = 'Experiment2/'

conditionFolder = ['DenseTrees/','PathOnly/']

fileNames = os.listdir(folderToParse)

for folderName in fileNames:

    for conditionFile in conditionFolder:

        conditionFileNames = os.listdir(folderToParse + folderName + '/' + conditionFile + 'FinalPositions/')

        outputFolder = folderToParse + folderName + '/' + conditionFile + 'Output_positionFiles/'

        if os.path.isdir(outputFolder):
            pass
        else:
            os.mkdir(outputFolder)

        for positionDataFile in conditionFileNames:

            print (folderName, conditionFile, positionDataFile)

            posDataPath = folderToParse + folderName + '/' + conditionFile + 'FinalPositions/' + positionDataFile

            output_filename = outputFolder + positionDataFile

            posData = pd.read_csv(posDataPath, sep=',', float_precision = None)

            removed, trimmedPosData = removeTheDuplicatePositionData(posData)


            print (removed, ' rows were removed from _', positionDataFile)

            trimmedPosData.to_csv(output_filename)
