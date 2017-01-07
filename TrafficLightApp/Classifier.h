//
//  Classifier.h
//  CaffeApp
//
//  Created by Takuya Matsuyama on 7/11/15.
//  Copyright (c) 2015 Takuya Matsuyama. All rights reserved.
//

#import "caffe/caffe.hpp"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
#include <iosfwd>
#include <memory>
#include <string>
#include <utility>
#include <vector>
#include <iomanip>

/* Pair (label, confidence) representing a prediction. */
typedef std::pair<std::string, float> Prediction;

class Classifier {
public:
    Classifier(const std::string& model_file,
             const std::string& trained_file,
             const std::string& mean_file,
             const std::string& label_file);
  
  std::vector<Prediction> Classify(const cv::Mat& img, int N = 5);
  
private:
  void SetMean(const std::string& mean_file);
  
  std::vector<float> Predict(const cv::Mat& img);
  
  void WrapInputLayer(std::vector<cv::Mat>* input_channels);
  
  void Preprocess(const cv::Mat& img,
                  std::vector<cv::Mat>* input_channels);
  
private:
    caffe::shared_ptr< caffe::Net<float> > net_;
  cv::Size input_geometry_;
  int num_channels_;
  cv::Mat mean_;
  std::vector<std::string> labels_;
  std::vector<cv::Mat> input_channels_;
};
