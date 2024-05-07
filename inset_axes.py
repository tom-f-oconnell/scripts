#!/usr/bin/env python3

import matplotlib.pyplot as plt

from mpl_toolkits.axes_grid1.inset_locator import inset_axes

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=[6, 3])

im1 = ax1.imshow([[1, 2], [2, 3]])
axins1 = inset_axes(
    ax1,
    width="50%",  # width: 50% of parent_bbox width
    height="5%",  # height: 5%
    loc="upper right",
)
axins1.xaxis.set_ticks_position("bottom")
fig.colorbar(im1, cax=axins1, orientation="horizontal", ticks=[1, 2, 3])

im = ax2.imshow([[1, 2], [2, 3]])
axins = inset_axes(
    ax2,
    width="5%",  # width: 5% of parent_bbox width
    height="50%",  # height: 50%

    # TODO what is this even doing? why is it on the right of the image then?
    # (it [or something] is required, as commenting it out seems to remove the colorbar)
    loc="lower left",

    # also didn't work (why?)
    #loc="lower right",
    # puts flush w/ to of axes (also on RIGHT), extending down half height
    #loc="upper left",

    # (0, 0, 1, 1) used if None
    bbox_to_anchor=(1.05, 0., 1, 1),
    #bbox_to_anchor=(1, 0., 1, 1),

    bbox_transform=ax2.transAxes,

    # TODO why use borderpad vs whatever epsilon is added to bbox_to_anchor[0]?
    #
    # was not flush w/ bottom unless this was set. bbox_to_anchor[0] set l/r distances,
    # not up/down.
    borderpad=0,
)
fig.colorbar(im, cax=axins, ticks=[1, 2, 3])

plt.show()
