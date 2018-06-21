1.功能模块如下：
######################################################################################
#               input the number and execute the module                              #
# 0. initialize the server just for new OS for your attention                        #
# 1. rename Administrator to zyadmin，update the description to Account for zhuyun   #
# 2. set random password for user and set the password never expires                 #
# 3. create new user and add the user to administrators' group                       #
# 4. enable remote desktop and update the port to 40022                              #
# 5. start and stop some service                                                     #
# 6. display sysinfo on desktop when join the domain for new OS                      #
# 7. rename the server's hostname                                                    #
# 8. reboot the server                                                               #
# 9. exit the script                                                                 #
######################################################################################
Please input the number that you want to execute the module:

0.在新系统上面初始化（切记只能用在新系统上面）。
1.重命名Administrator为zyadmin，并修改描述信息。
2.为用户设置密码并修改为永不过期。
3.创建新的用户并添加到管理员组。
4.开启远程桌面并修改远程桌面端口为40022。
5.开启和关闭一些服务。
6.对加入域的新的服务器，打印系统信息到桌面
7.修改计算机名称。
8.重启服务器。
9.退出脚本的执行。

注意：0模块包括1-8中所有的功能，新购买的系统如果不加域只运行0模块即可！如果加入域，在系统重启之后，
再次运行初始化脚本并且选择模块6，然后根据提示注销用户即可。在系统重启之前务必把zyadmin以及新建用户
的密码更到Rattic里面去，切记！！！