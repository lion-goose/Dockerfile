1. 将脚本命名为`redrain.py`，修改为你自己的信息。
2. 在`redrain.py`同目录下，建立`docker-compose.yml`文件，内容如下：

```
version: "2.0"
services:
  redrain:
    image: nevinee/redrain
    container_name: redrain
    restart: always
    tty: true
    network_mode: bridge
    hostname: redrain
    volumes:
      - ./:/redrain
```

1. 在上述两个文件的保存目录下创建容器（自行安装好docker-compose）。

   ```
   docker-compose up -d
   ```

2. 首次部署容器时，需要按以下流程初始化。

   ```
   docker exec -it redrain pm2 stop redrain
   docker exec -it redrain python redrain.py
   # 按提示输入信息以后，Ctrl+C退出运行，然后以下一条命令重启容器
   docker-compose restart
   ```

3. 后续修改`redrain.py`，容器会自动重启pm2进程，无需重启容器。重启容器、更新容器、重建容器不再需要进行初始化操作，容器启动后自动启动`redrain.py`。

4. 查看日志：

   ```
   docker exec -it redrain pm2 logs
   docker exec -it redrain pm2 monit
   ```