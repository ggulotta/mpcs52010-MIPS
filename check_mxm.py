import array
import sys
import numpy as np

a = array.array('i')
with open('A.in', 'r') as f:
    a.fromfile(f, 64)

b = array.array('i')
with open('B.in', 'r') as f:
    b.fromfile(f, 64)

c = array.array('i')
with open('C.out', 'r') as f:
    c.fromfile(f, 64)

a = np.matrix(np.reshape(a, (8, 8)))
b = np.matrix(np.reshape(b, (8, 8)))
c = np.matrix(np.reshape(c, (8, 8)))

print('Computed by numpy: \n {0} \n'.format(np.matmul(a, b)))
print('Computed by mxm_final.asm: \n {0}'.format(c))
