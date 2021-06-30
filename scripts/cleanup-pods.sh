#!/bin/bash

function fast {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Terminating | awk '{print "kubectl delete pod --grace-period=0 " $2 " -n " $1}' > /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep -v " 0 " | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep -v Running | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function slow {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Terminating | awk '{print "kubectl delete pod --grace-period=0 " $2 " -n " $1}' > /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep -v " 0 " | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep -v Running | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  sed -i '0~1 a\sleep 60'  /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function completed {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Completed | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function error {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Error | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function evicted {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Evicted | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function crashloopbackoff {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep CrashLoopBackOff | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function matchnodeselector {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep MatchNodeSelector | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function unknown {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces | grep -v openshift-sdn  | grep Unknown | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1 " --force --grace-period=0"}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function containercreating {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces  | grep ContainerCreating | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function imagepullbackoff {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces  | egrep "ImagePullBackOff|ErrImagePull" | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function oomkilled {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces  | egrep "OOMKilled" | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

function shutdown {
  rm -rf /tmp/fresh.sh
  kubectl get pods --all-namespaces  | egrep "Shutdown" | grep -v NAME | awk '{print "kubectl delete pod " $2 " -n " $1}' >> /tmp/fresh.sh
  bash /tmp/fresh.sh
  rm -rf /tmp/fresh.sh
}

case $1 in
  --fast)
  fast
  exit
  ;;
  --slow)
  slow
  exit
  ;;
  --completed)
  completed 
  exit
  ;;
  --error)
  error
  exit
  ;;
  --evicted)
  evicted
  exit
  ;;
  --oomkilled)
  oomkilled
  exit
  ;;
  --crashloopbackoff)
  crashloopbackoff
  exit
  ;;
  --matchnodeselector)
  matchnodeselector
  exit
  ;;
  --unknown)
  unknown
  exit
  ;;
  --containercreating)
  containercreating
  exit
  ;;
  --imagepullbackoff)
  imagepullbackoff
  exit
  ;;
  --shutdown)
  shutdown
  exit
  ;;

  -h|--help|*)
  echo "LSD Pod Freshen up Script"
  echo "Deletes all pods that are not running and that have had any restarts"
  echo ""
  echo "  --fast              | Delete all pods at the same time"
  echo "  --slow              | Delete all pods with a break between each deletion"
  echo "  --error             | Delete all pods marked as Error"
  echo "  --evicted           | Delete all pods marked as Evicted"
  echo "  --oomkilled         | Delete all pods marked as OOMKilled"
  echo "  --unknown           | Delete all pods marked as Unknown"
  echo "  --completed         | Delete all pods marked as Completed"
  echo "  --crashloopbackoff  | Delete all pods marked as CrashLoopBackOff"
  echo "  --containercreating | Delete all pods marked as ContainerCreating"
  echo "  --matchnodeselector | Delete all pods marked as MatchNodeSelector"
  echo "  --imagepullbackoff  | Delete all pods marked as ImagePullBackOff and ErrImagePull"
  echo "  --shutdown          | Delete all pods marked as Shutdown"
  echo ""
  exit
  ;;
esac
