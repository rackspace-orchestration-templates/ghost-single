import re
from fabric.api import env, hide, run, task
from envassert import detect, file, group, package, port, process, service, \
    user


def ghost_is_responding():
    with hide('running', 'stdout'):
        homepage = run("wget --quiet --output-document - http://localhost/")
        if re.search('Ghost', homepage):
            return True
        else:
            return False


@task
def check():
    env.platform_family = detect.detect()

    assert package.installed("nginx")
    assert package.installed("mysql-server-5.5")
    assert file.exists("/usr/local/bin/node")
    assert file.exists("/usr/local/bin/npm")
    assert port.is_listening(80)
    assert port.is_listening(2368)
    assert port.is_listening(3306)
    assert user.exists("ghost")
    assert group.is_exists("ghost")
    assert user.is_belonging_group("ghost", "www-data")
    assert process.is_up("nginx")
    assert process.is_up("node")
    assert process.is_up("mysqld")
    assert service.is_enabled("nginx")
    assert service.is_enabled("mysqld")
    assert ghost_is_responding(), 'Ghost did not respond as expected'
