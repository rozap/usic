from fabric.api import *
from fabric.contrib.console import confirm
from fabric.colors import *
from os import listdir
from os.path import isdir, join
from distutils.version import StrictVersion


env.hosts = ['usic']
env.use_ssh_config = True

#REMOTE
base_dir = "/var/sites/usic"
log_dir = "/var/log/usic"
media_dir = "/var/sites/usic_media"

#LOCAL
releases = "./rel/usic/releases"
archive_name = "usic.tar.gz"

def check_deploy():
    local('mix test')

def make_dirs():
    sudo("mkdir -p {base_dir}".format(base_dir = base_dir))
    sudo("mkdir -p {log_dir}".format(log_dir = log_dir))
    sudo("mkdir -p {media_dir}".format(media_dir = media_dir))

    sudo("chown -R usic:usic {base_dir}".format(base_dir = base_dir))
    sudo("chown -R usic:usic {log_dir}".format(log_dir = log_dir))
    sudo("chown -R usic:usic {media_dir}".format(media_dir = media_dir))

def ensure_packages():
    with hide('output'):
        sudo("apt-get update")
        sudo("apt-get install -y htop python-pip tmux vim libav-tools")
    sudo("pip install --upgrade youtube_dl")


def build_release():
    print(green("Building release"))

    local("gulp deploy")
    local("mix phoenix.digest")
    local("MIX_ENV=prod mix release")

    rels = [ StrictVersion(f) for f in listdir(releases) if isdir(join(releases,f)) ]
    release_dir = join(releases, str(max(rels)))
    return archive_name, join(release_dir, archive_name)


def update():
    archive_name, archive = build_release()
    put(archive, "/tmp")

    make_dirs()

    with cd(base_dir):
        sudo("tar xfz /tmp/{archive_name}".format(
            archive_name = archive_name,
            base_dir = base_dir
        ))
    put("deploy/upstart.conf", "/etc/init/usic.conf", use_sudo = True)


@task
def deploy():
    check_deploy()
    print(green("starting deploy"))
    ensure_packages()
    update()
