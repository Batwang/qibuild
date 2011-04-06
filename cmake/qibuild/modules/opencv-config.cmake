## Copyright (C) 2011 Aldebaran Robotics

clean(OPENCV)
# Old API
# include <cv.h>
fpath(OPENCV cv.h PATH_SUFFIXES opencv)
# include <opencv/cv.h>
fpath(OPENCV opencv/cv.h)

# New API:
# include <opencv2/cv.hpp>
# fpath(OPENCV opencv2/cp.hpp PATH_SUFFIXES opencv2)


flib(OPENCV OPTIMIZED NAMES cv      cv200       opencv_legacy)
flib(OPENCV DEBUG     NAMES cv      cv200d      opencv_legacy)
flib(OPENCV OPTIMIZED NAMES cvaux   cvaux200    opencv_contrib)
flib(OPENCV DEBUG     NAMES cvaux   cvaux200d   opencv_contrib)
flib(OPENCV OPTIMIZED NAMES cxcore  cxcore200   opencv_core)
flib(OPENCV DEBUG     NAMES cxcore  cxcore200d  opencv_core)
flib(OPENCV OPTIMIZED NAMES highgui highgui200  opencv_highgui)
flib(OPENCV DEBUG     NAMES highgui highgui200d opencv_highgui)
flib(OPENCV OPTIMIZED NAMES ml      ml200d      opencv_ml)
flib(OPENCV DEBUG     NAMES ml      ml200       opencv_ml)
export_lib(OPENCV)
