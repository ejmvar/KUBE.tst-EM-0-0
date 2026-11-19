#!/bin/bash

kind load docker-image localhost/joke-app:1.0

m=$(
  cat <<LLLL

  Every 1,0s: kubectl get pod                                   qq-l230: Tue Nov 17 16:19:15 2026

NAME                                READY   STATUS         RESTARTS      AGE
joke-deployment-cfd69d5d6-gcg24     0/1     ErrImagePull   0             10s


LLLL
)
