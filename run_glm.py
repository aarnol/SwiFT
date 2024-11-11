import numpy as np
import pandas as pd
import os
from nilearn.glm.second_level import SecondLevelModel
from nilearn.plotting import plot_stat_map
from nilearn.image import math_img, load_img, mean_img, smooth_img
import nibabel as nib
import random
# Compute the mean image across axis 3 for each file
root1 = "/scratch/alpine/alar6830/WM_nback_labels/"


subjects = [os.path.join(root1, x) for x in os.listdir(root1)]
sub_names = set([os.path.basename(sub)[0:6] for sub in subjects])
subjects = random.sample(sub_names, 100)    
contrast_0back = sorted([os.path.join(root1, sub+"040.nii.gz") for sub in subjects ])
contrast_2back = sorted([os.path.join(root1, sub+"041.nii.gz") for sub in subjects ])
# Filter only the indices where both files exist
valid_indices = [
    i for i in range(len(subjects))
    if os.path.exists(contrast_0back[i]) and os.path.exists(contrast_2back[i])
]

# Filter the lists using the valid indices
contrast_0back = [contrast_0back[i] for i in valid_indices]
contrast_2back = [contrast_2back[i] for i in valid_indices]
assert len(contrast_0back) == len(contrast_2back), "Mismatch in 0-back and 2-back files."

# Compute difference maps and ensure each is 3D
difference_maps = []
for i in range(len(contrast_0back)):
    print(contrast_0back[i])
    print(contrast_2back[i])
    img1 = load_img(contrast_0back[i])
    img2 = load_img(contrast_2back[i])
    
    # If the images are 4D, average across time to make them 3D
    if img1.ndim == 4:
        img1 = mean_img(img1)
    if img2.ndim == 4:
        img2 = mean_img(img2)
    smoothed_img1 = smooth_img(img1, fwhm=4)
    smoothed_img2 = smooth_img(img2, fwhm=4)
    # Compute the difference map
    diff_img = math_img("img2 - img1", img1=smoothed_img1, img2=smoothed_img2)
    difference_maps.append(diff_img)


design_matrix = pd.DataFrame([1] * len(difference_maps), columns=["intercept"])




# Create the design matrix: 1 for group1 (2-back), 0 for group2 (0-back)

second_level_model = SecondLevelModel()

# Fit the model with individual task maps or difference maps
if 'difference_maps' in locals():
    second_level_model = second_level_model.fit(difference_maps, design_matrix=design_matrix)
else:
    # Flatten both lists to pass all individual maps at once
    all_contrast_maps = contrast_0back + contrast_2back
    second_level_model = second_level_model.fit(all_contrast_maps, design_matrix=design_matrix)





from scipy.stats import t
from nilearn.image import threshold_img
# Calculate degrees of freedom
n_subjects = len(difference_maps)
df = n_subjects - 1

# Get the critical t-value for a one-tailed test at p < 0.05
t_threshold = t.ppf(0.99, df)  # 0.95 for one-tailed, p < 0.05

# Compute the t-map instead of the z-map
t_map = second_level_model.compute_contrast(output_type='stat')

# Threshold the t-map with the computed t-value
thresholded_map = threshold_img(t_map, threshold=t_threshold)





# Plot and save the transformed thresholded map
plot_stat_map(
    thresholded_map,
    display_mode='mosaic',
    title='2-back > 0-back (Transformed)',
    threshold=t_threshold,
    cmap='cold_hot',
    output_file="transformed_body_glm_ttest.png"
)



exit()