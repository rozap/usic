from fabric.api import *
from fabric.contrib.console import confirm
from fabric.colors import *

env.hosts = ['usic']

def check_deploy():
    local('mix test')

@task
def deploy():
    check_deploy()


    print(green("starting deploy"))