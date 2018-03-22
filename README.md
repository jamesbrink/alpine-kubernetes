# Alpine Kubernetes Box
An Alpine Linux Vagrant Box containing Kubernetes


This is a simple Alpine Linux box containing a recent build of Kubernets v 1.9.6

## To-do
`kubeadm` does not support the Alpine Linux init system `OpenRC`, so the service needs to be started manually after invoking `kubeadm init`
