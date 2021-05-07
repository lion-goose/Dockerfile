# 每2天的23:50分清理一次日志
58 23 */1 * * rm -rf /logs/*.log

0 */3 * * * cd /get_CCB/ && python3 keepAlive.py  |ts >> /logs/jd_daily_lottery.log 2>&1
5 0 * * * cd /get_CCB/ && python3 main.py  |ts >> /logs/jd_daily_lottery.log 2>&1
