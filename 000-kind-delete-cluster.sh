#!/bin/bash

kind delete cluster -n em-demo-0-0-0
kind delete cluster -n kind

kind delete cluster -n em-tst-00
kind delete cluster -n kind-em-tst-00
