from fabric.api import env, run, task
from envassert import detect, file, group, package, port, process, service, \
    user


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
