# Color palette generator

Generates colors with similar lightness and saturation that are
available for all hues in sRGB color space.

## Why you should use it

The tones over all hues have all the same perceptual chroma and lightness,
using the OKLAB color space.

This would not be the case with the HSL/HSV colorspace, as it it based on sRGB.

You should be able to get a very uniform style of an UI if you need multiple hues.

## Why you should not use it

Good color palettes also change the hue a bit for each tone.
This can have multiple reasons.

- giving more contrast
- beeing able to fit more shades in sRGB

The sRGB color space would not allow to display as many hues for bright
and dark tones as would be possible by OKLAB.

Other colorspaces will shift the hue for those shades in an area
that can be displayed by sRGB to allow that.
