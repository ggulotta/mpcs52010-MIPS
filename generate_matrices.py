import array
import random
import sys


filenames = ['A.in', 'B.in']

for filename in filenames:
	# Populate 8x8 row-major order matrix
	l = [ random.randint(0, 10) for i in xrange(64) ]

	a = array.array('i', l)
	with open(filename, 'wb') as f:
		a.tofile(f)

	# Print matrix
	l = [ l[i:i+8] for i in xrange(64) if i%8==0 ]
	print "Created '" + filename + "' as :"
	for i in xrange(8):
		print l[i]
	print
