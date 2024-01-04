import numpy as np
from make_image import make_image
from produce_image import produce_image, matplotlibStyle
from make_segments import make_segments
import time

start_time = time.time()
# Generate array of function outputs

def f(z):
    return np.cos(z*1j)*z**3j

outputs = make_image((-2,2),(-2,2),800,f)

# Tag each output with phase and distance categories

segments = (10,1)

skeleton = make_segments(outputs,segments)

end_time = time.time()
print(end_time-start_time)

# Color outputs according to their category

cmap = matplotlibStyle('magma',segments)

start_time=time.time()
produce_image(skeleton,cmap)
end_time=time.time()
print(end_time-start_time)






