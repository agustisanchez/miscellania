"""
 Converts from European Excel CSV file format to 'real' CVS file format
"""
import codecs

with codecs.open("prom94.csv", "r", "iso-8859-1") as fInput:
    data = fInput.readlines()
with codecs.open("test.csv", "w", "iso-8859-1") as fOutput:
    for line in data:
        values = line.split(';')
        fOutput.write('"')
        fOutput.write(values[0])
        fOutput.write('",')
        fOutput.write(values[1])

