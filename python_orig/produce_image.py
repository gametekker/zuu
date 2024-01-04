import matplotlib.pyplot as plt
import numpy as np
import matplotlib.cm as cm

# shading algorithm:
#   {}
# [][][]
#   []

#   {}
# [][]{}
#   []

#   {}
# [][]{}
#   {}

#   {}
# {}[]{}
#   {}

# gpu: superfast using shared memory
# [   threads1   ][   threads2   ]
# [   threads3   ][   threads4   ]
# [   threads4   ][   threads5   ]
# block of threads:
# compute all even pixels, each bin a unique value, store in shared memory
# lock (wait until all are finished)
# compute all odd pixels, each bin a unique value, store in shared memory

def produce_image(skeleton, cmap, title=None):
    #create image
    image=np.zeros(shape=(*skeleton.shape[:-1],4))
    for i,j,_ in np.ndindex(skeleton.shape):
        x1,x2=skeleton[i,j]
        image[i, j, :] = cmap[int(x1),int(x2)]

    plt.imshow(image)
    if title:
        plt.savefig(f'{title}.png')
    else:
        plt.show()


def matplotlibStyle(colormap_name, segments):
    colormap = cm.get_cmap(colormap_name, segments[0])
    colors = [colormap(i) for i in range(colormap.N)]
    return luminanceColormap(colors, segments[1])

class luminanceColormap:
    def __init__(self, colors, shades_for_each_color=16):
        self.colors = np.array(colors)
        self.shades_for_each_color = shades_for_each_color
        self._generate_colormap()

    def _generate_colormap(self):
        self.colormap = np.zeros((len(self.colors), self.shades_for_each_color, 4))

        for i, color in enumerate(self.colors):
            for j in range(self.shades_for_each_color):
                shade_factor = j / self.shades_for_each_color
                shaded_color = color * (1 - shade_factor) + np.array([0, 0, 0, 1]) * shade_factor
                self.colormap[i, j] = shaded_color

    def __getitem__(self, idx):
        return tuple(self.colormap[idx])

    @property
    def shape(self):
        return self.colormap.shape[:2]
