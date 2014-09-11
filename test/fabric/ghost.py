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

    assert package.installed("nginx"), 'nginx not installed'
    assert package.installed("mysql-server-5.5"), 'mysql-server-5.5 not installed'
    assert file.exists("/usr/local/bin/node"), 'node not found'
    assert file.exists("/usr/local/bin/npm"), 'npm not found'
    assert port.is_listening(80), '80/nginx is not listening'
    assert port.is_listening(2368), '2368/node is not listening'
    assert port.is_listening(3306), '3306/mysqld is not listening'
    assert user.exists("ghost"), 'ghost user does not exist'
    assert group.is_exists("ghost"), 'ghost group does not exist'
    assert user.is_belonging_group("ghost", "www-data"), 'ghost user not in group www-data'
    assert process.is_up("nginx"), 'nginx is not running'
    assert process.is_up("node"), 'node is not running'
    assert process.is_up("mysqld"), 'mysqld is not running'
    assert service.is_enabled("nginx"), 'nginx service not enabled'
    assert service.is_enabled("mysqld"), 'mysqld service not enabled'
    assert ghost_is_responding(), 'Ghost did not respond as expected'
