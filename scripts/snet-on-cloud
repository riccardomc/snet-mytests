#!/usr/bin/env python

import os
import time
import boto
import boto.ec2
import subprocess
import shlex
from optparse import OptionParser, OptionGroup

def poll_instance_state(instance, state, attempts = 90, delay = 2):
  """ 
  Polls the state of the instance until timeout or it becames True.

  @return On success: the id of the instance 
          On failure: None
  """
  if not instance:
    return None

  instance_state = instance.update(validate = True)
  for i in range(1, attempts):
    instance_state = instance.update(validate = True)
    if instance_state != state:
      print "Instance", instance.id, "is", instance.state
      time.sleep(2)
    else:
      break

  if instance_state != state:
    return None

  return instance.id


def run_instance(connection, ami,
    key_pair = None, inst_type = None, sec_group = None):
  reservation = connection.run_instances(ami,
      key_name = key_pair,
      instance_type = inst_type,
      security_groups = [sec_group])
  instance = reservation.instances[0]

  return poll_instance_state(instance, 'running')


def terminate_instance(connection, id):
  terminated = connection.terminate_instances(instance_ids=[id])
  instance = terminated[0]

  return poll_instance_state(instance, 'terminated')


def ssh_copy(username, key, host, remote_dir, exe):
  cmd = ['/usr/bin/scp',
      '-q',
      '-o',
      'StrictHostKeyChecking no',
      '-i',
      key,
      exe,
      username + '@' + host + ":" + remote_dir]

  return subprocess.call(cmd);


def ssh_run(username, key, host, remote_dir, exe, args):
  cmd = ['/usr/bin/ssh',
      '-q',
      '-o',
      'StrictHostKeyChecking no',
      '-i',
      key,
      username + '@' + host,
      os.path.join(remote_dir, os.path.basename(exe))] + args

  return subprocess.call(cmd);


def ssh_snet_run(username, key, host, remote_dir, exe, args):
  return ssh_run(username, key, host, remote_dir, exe, ['-hostn', host] + args)


def run_on_instance(connection, id, username, key,
    remote_dir, exe, args, attempts = 10):
  """Attempt to run exe on the remote instance id"""

  reservation = connection.get_all_instances(instance_ids=[id])
  instance = reservation[0].instances[0]

  for i in range(1, attempts):
    print "SSH attempt %d/%d" % (i, attempts)
    ret = ssh_copy(username, key, instance.public_dns_name, remote_dir, exe)
    if (ret == 0):
      break
    else:
      time.sleep(2)
  
  if ret != 0:
    return ret

  ret = ssh_snet_run(username, key, instance.public_dns_name, remote_dir, exe, args)

  return ret


if __name__ == "__main__":

  usage = "usage: %prog [OPTIONS] <EXE> [<--> [ARGS]]"
  parser = OptionParser(usage=usage)

  parser.add_option("-i", "--id", action="store",
    type="string", dest="instance",
    default="",
    help="Instance id where EXE will be run. If specified, \
        instance creation will be skipped")

  parser.add_option("-g", "--region", action="store",
    type="string", dest="region",
    default="eu-west-1",
    help="AWS region in which the instance will be started")

  parser.add_option("-a", "--ami", action="store",
    type="string", dest="ami",
    default="ami-f1a5b285",
    help="AMI id of the S-Net enabled image")

  parser.add_option("-k", "--key", action="store",
    type="string", dest="key",
    default=os.path.expanduser("~/.ssh/snetdev.pem"),
    help="SSH key to use to access the instances")

  parser.add_option("-p", "--key-pair", action="store",
    type="string", dest="key_pair",
    default="snetdev",
    help="AWS key pair to use. Must match KEY")

  parser.add_option("-s", "--security-group", action="store",
    type="string", dest="sec_group",
    default="unsafe",
    help="AWS security group in which the instance will be placed")

  parser.add_option("-t", "--type", action="store",
    type="string", dest="inst_type",
    default="t1.micro",
    help="AWS type of the instances")

  parser.add_option("-u", "--username", action="store",
    type="string", dest="username",
    default="ubuntu",
    help="username that will execute EXE on the instance")

  parser.add_option("-r", "--remote-dir", action="store",
    type="string", dest="remote_dir",
    default="/tmp",
    help="remote dir where the EXE binary will be copied")

  parser.add_option("-A", "--keep-alive", action="store_true",
    dest="keep_alive", default=False,
    help="Do not terminate the instance when done. Default: True when\
        -i ID is provided. False otherwise.")

  (options, args) = parser.parse_args()

  executable = args[0] #FIXME: print usage if missing
  exe_args = args[1:]

  print "Establishing connection to cloud provider...",
  connection = boto.ec2.connect_to_region(options.region)
  print "OK"

  instance = options.instance
  if instance == "":
    print "Starting new instance"
    instance = run_instance(connection, options.ami,
        key_pair = options.key_pair,
        inst_type = options.inst_type,
        sec_group = options.sec_group)
  else:
    options.keep_alive = True
    
  print "Running on instance: %s" % instance
  run_on_instance(connection, instance, options.username, 
      options.key, options.remote_dir, executable, exe_args)

  print "Terminating Instance:", not options.keep_alive
  if not options.keep_alive:
    terminate_instance(connection, instance)
