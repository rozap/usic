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
    local('mix clean')
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
        sudo("apt-get install -y htop python-pip tmux vim libav-tools erlang-dev postgresql-9.3")
    sudo("pip install --upgrade youtube_dl")


def build_release():
    print(green("Building release"))
    with shell_env(MIX_ENV='prod'):
        local('mix compile')
        local("gulp deploy")
        local("mix phoenix.digest")
        local("mix release")

        rels = [ StrictVersion(f) for f in listdir(releases) if isdir(join(releases,f)) ]
        release_dir = join(releases, str(max(rels)))
        return archive_name, join(release_dir, archive_name)


def ship():
    archive_name, archive = build_release()
    put(archive, "/tmp")

    make_dirs()

    with cd(base_dir):
        sudo("tar xfz /tmp/{archive_name}".format(
            archive_name = archive_name,
            base_dir = base_dir
        ))
    put("deploy/upstart.conf", "/etc/init/usic.conf", use_sudo = True)


def migrate(version):
    artifact = 'usic-%s' % version
    print(cyan("""
        To migrate, run

            sudo {base_dir}/bin/usic

        And then in the console:

            Ecto.Migrator.run(Usic.Repo, "/var/sites/usic/lib/{artifact}/priv/repo/migrations", :up, all: true)
    """.format(
        base_dir = base_dir,
        artifact = artifact
    )))
    return prompt('Are your migrations in order?', default = 'no')

def upgrade(version):
    # ~~ we are living in the future ~~
    # ~~ the future is 1980 ~~
    print(yellow("Upgrading to {version}".format(version = version)))
    with cd(base_dir):
        sudo("bin/usic upgrade {version}".format(version = version))



@task
def rollback(version):
    print(yellow("Downgrade to {version}".format(version = version)))
    with cd(base_dir):
        sudo("bin/usic downgrade {version}".format(version = version))


@task
def deploy(version):
    check_deploy()
    print(green("starting deploy"))
    ensure_packages()
    ship()

    res = migrate(version)

    if res == 'yes':
        upgrade(version)
    else:
        print(red("Not upgrading until migrations are done"))
