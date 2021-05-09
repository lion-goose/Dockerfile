# -*- coding: utf-8 -*-
# @Author    : iouAkira(lof)
# @mail      : e.akimoto.akira@gmail.com
# @CreateTime: 2020-11-02
# @UpdateTime: 2021-03-25

import math
import os
import subprocess
from subprocess import TimeoutExpired
from MyQR import myqr
import requests
import time
import logging
import re
from urllib.parse import quote, unquote

import telegram.utils.helpers as helpers
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackQueryHandler

# 启用日志
logging.basicConfig(format='%(asctime)s-%(name)s-%(levelname)s=> [%(funcName)s] %(message)s ', level=logging.INFO)
logger = logging.getLogger(__name__)

_base_dir = '/scripts/'
_logs_dir = '%slogs/' % _base_dir
_docker_dir = '%sdocker/' % _base_dir
_bot_dir = '%sbot/' % _docker_dir
_share_code_conf = '%sgen_code_conf.list' % _logs_dir

if 'GEN_CODE_LIST' in os.environ:
    share_code_conf = os.getenv("GEN_CODE_LIST")
    if share_code_conf.startswith("/"):
        _share_code_conf = share_code_conf


def start(update, context):
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        spnode_readme = ""
        if "DISABLE_SPNODE" not in os.environ:
            spnode_readme = "/spnode 获取可执行脚本的列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/spnode /scripts/jd_818.js)\n\n" \
                            "使用bot交互+spnode后 后续用户的cookie维护更新只需要更新logs/cookies.list即可\n" \
                            "使用bot交互+spnode后 后续执行脚本命令请使用spnode否者无法使用logs/cookies.list的cookies执行脚本，定时任务也将自动替换为spnode命令执行\n" \
                            "spnode功能概述示例\n\n" \
                            "spnode conc /scripts/jd_bean_change.js 为每个cookie单独执行jd_bean_change脚本（伪并发\n" \
                            "spnode 1 /scripts/jd_bean_change.js 为logs/cookies.list文件里面第一行cookie账户单独执行jd_bean_change脚本\n" \
                            "spnode jd_XXXX /scripts/jd_bean_change.js 为logs/cookies.list文件里面pt_pin=jd_XXXX的cookie账户单独执行jd_bean_change脚本\n" \
                            "spnode /scripts/jd_bean_change.js 为logs/cookies.list所有cookies账户一起执行jd_bean_change脚本\n" \
                            "请仔细阅读并理解上面的内容，使用bot交互默认开启spnode指令功能功能。\n" \
                            "如需____停用___请配置环境变量 -DISABLE_SPNODE=True"
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text="限制自己使用的JD Scripts拓展机器人\n" \
                                      "\n" \
                                      "/start 开始并获取指令说明\n" \
                                      "/node 获取可执行脚本的列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/node /scripts/jd_818.js) \n" \
                                      "/git 获取可执行git指令列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/git -C /scripts/ pull)\n" \
                                      "/logs 获取logs下的日志文件列表，选择对应名字可以下载日志文件\n" \
                                      "/env 获取系统环境变量列表。(拓展使用：设置系统环境变量，例：/env export JD_DEBUG=true，环境变量只针对当前bot进程生效) \n" \
                                      "/cmd 执行执行命令。参考：/cmd ls -l 涉及目录文件操作请使用绝对路径,部分shell命令开放使用\n" \
                                      "/crontab 查看定时任务。\n" \
                                      "/eikooc_dj_teg 获取cookie。\n" \
                                      "/gen_long_code 长期活动互助码提交消息生成\n" \
                                      "/gen_temp_code 短期临时活动互助码提交消息生成\n" \
                                      "/gen_daily_code 每天变化互助码活动提交消息生成\n\n%s" % spnode_readme)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def node(update, context):
    """关于定时任务中nodejs脚本的相关操作
    """
    if is_admin(update.message.from_user.id):
        commands = update.message.text.split()
        commands.remove('/node')
        if len(commands) > 0:
            cmd = 'node %s' % (' '.join(commands))
            try:

                out_bytes = subprocess.check_output(
                    cmd, shell=True, timeout=600, stderr=subprocess.STDOUT)

                out_text = out_bytes.decode('utf-8')

                if len(out_text.split()) > 50:

                    msg = context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % cmd)), chat_id=update.effective_chat.id,
                        parse_mode=ParseMode.MARKDOWN_V2)

                    log_name = '%sbot_%s_%s.log' % (
                        _logs_dir, 'node', os.path.splitext(commands[-1])[0])

                    with open(log_name, 'a+') as wf:
                        wf.write(out_text)

                    msg.reply_document(
                        reply_to_message_id=msg.message_id, quote=True, document=open(log_name, 'rb'))
                else:

                    context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (cmd, out_text))),
                        chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except TimeoutExpired:

                context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行超时 ←←← ' % (
                    cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except:

                context.bot.sendMessage(
                    text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行出错，请检查确认命令是否正确 ←←← ' % (
                        cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise
        else:
            reply_markup = get_reply_markup_btn('node')
            update.message.reply_text(text='```{}```'.format(helpers.escape_markdown(' ↓↓↓ 请选择想要执行的nodejs脚本 ↓↓↓ ')),
                                      reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def spnode(update, context):
    """关于定时任务中nodejs脚本的相关操作
    """
    if is_admin(update.message.from_user.id):
        commands = update.message.text.split()
        commands.remove('/spnode')
        if len(commands) > 0:
            cmd = 'spnode %s' % (' '.join(commands))
            try:

                out_bytes = subprocess.check_output(
                    cmd, shell=True, timeout=600, stderr=subprocess.STDOUT)

                out_text = out_bytes.decode('utf-8')

                if len(out_text.split()) > 50:

                    msg = context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % cmd)), chat_id=update.effective_chat.id,
                        parse_mode=ParseMode.MARKDOWN_V2)
                    file_name = re.split(r"\W+", cmd)
                    if 'js' in file_name:
                        file_name.remove('js')
                    log_name = '%sbot_%s_%s.log' % (_logs_dir, 'spnode', file_name[-1])

                    with open(log_name, 'a+') as wf:
                        wf.write(out_text)

                    msg.reply_document(
                        reply_to_message_id=msg.message_id, quote=True, document=open(log_name, 'rb'))
                else:

                    context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (cmd, out_text))),
                        chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except TimeoutExpired:

                context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行超时 ←←← ' % (
                    cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except:

                context.bot.sendMessage(
                    text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行出错，请检查确认命令是否正确 ←←← ' % (
                        cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise
        else:
            reply_markup = get_reply_markup_btn('spnode')
            update.message.reply_text(text='```{}```'.format(helpers.escape_markdown(' ↓↓↓ 请选择想要执行的nodejs脚本 ↓↓↓ ')),
                                      reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def git(update, context):
    """关于/scripts仓库的git相关操作
    """
    if is_admin(update.message.from_user.id):
        commands = update.message.text.split()
        commands.remove('/git')
        if len(commands) > 0:
            cmd = 'git %s' % (' '.join(commands))
            try:

                out_bytes = subprocess.check_output(
                    cmd, shell=True, timeout=600, stderr=subprocess.STDOUT)

                out_text = out_bytes.decode('utf-8')

                if len(out_text.split()) > 50:

                    msg = context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % cmd)), chat_id=update.effective_chat.id,
                        parse_mode=ParseMode.MARKDOWN_V2)

                    log_name = '%sbot_%s_%s.log' % (
                        _logs_dir, 'git', os.path.splitext(commands[-1])[0])

                    with open(log_name, 'a+') as wf:
                        wf.write(out_text)

                    msg.reply_document(
                        reply_to_message_id=msg.message_id, quote=True, document=open(log_name, 'rb'))
                else:

                    context.bot.sendMessage(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (cmd, out_text))),
                        chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except TimeoutExpired:

                context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行超时 ←←← ' % (
                    cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

            except:

                context.bot.sendMessage(
                    text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行出错，请检查确认命令是否正确 ←←← ' % (
                        cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise

        else:
            reply_markup = get_reply_markup_btn('git')

            update.message.reply_text(text='```{}```'.format(helpers.escape_markdown(' ↓↓↓ 请选择想要执行的git指令 ↓↓↓ ')),
                                      reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def env(update, context):
    """env 环境变量相关操作
    """
    if is_admin(update.message.from_user.id):
        commands = update.message.text.split()
        commands.remove('/env')
        if len(commands) == 2 and (commands[0]) == 'export':

            try:
                envs = commands[1].split('=')
                os.putenv(envs[0], envs[1])

                context.bot.sendMessage(text='```{}```'.format(
                    helpers.escape_markdown(' ↓↓↓ 环境变量设置成功 ↓↓↓ \n\n%s ' % ('='.join(envs)))),
                    chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
            except:
                context.bot.sendMessage(
                    text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行出错，请检查确认命令是否正确 ←←← ' % (
                        ' '.join(commands)))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise

        elif len(commands) == 0:
            out_bytes = subprocess.check_output(
                'env', shell=True, timeout=600, stderr=subprocess.STDOUT)

            out_text = out_bytes.decode('utf-8')

            if len(out_text.split()) > 50:

                msg = context.bot.sendMessage(text='```{}```'.format(
                    helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % 'env')), chat_id=update.effective_chat.id,
                    parse_mode=ParseMode.MARKDOWN_V2)

                log_name = '%sbot_%s.log' % (_logs_dir, 'env')

                with open(log_name, 'a+') as wf:
                    wf.write(out_text + '\n\n')

                msg.reply_document(
                    reply_to_message_id=msg.message_id, quote=True, document=open(log_name, 'rb'))
            else:

                context.bot.sendMessage(text='```{}```'.format(
                    helpers.escape_markdown(' ↓↓↓ env 执行结果 ↓↓↓ \n\n%s ' % out_text)),
                    chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
        else:
            context.bot.sendMessage(text='```{}```'.format(
                helpers.escape_markdown(' →→→ env 指令不正确，请参考说明输入 ←←← ')), chat_id=update.effective_chat.id,
                parse_mode=ParseMode.MARKDOWN_V2)

    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def crontab(update, context):
    """关于crontab 定时任务相关操作
    """
    reply_markup = get_reply_markup_btn('crontab_l')

    if is_admin(update.message.from_user.id):
        try:
            update.message.reply_text(text='```{}```'.format(helpers.escape_markdown(' ↓↓↓ 下面为定时任务列表，请选择需要的操作 ↓↓↓ ')),
                                      reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)
        except:
            raise
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def logs(update, context):
    """关于_logs_dir目录日志文件的相关操作
    """
    reply_markup = get_reply_markup_btn('logs')

    if is_admin(update.message.from_user.id):
        update.message.reply_text(text='```{}```'.format(helpers.escape_markdown(' ↓↓↓ 请选择想想要下载的日志文件或者清除所有日志 ↓↓↓ ')),
                                  reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def callback_run(update, context):
    """执行按钮响应回调方法处理按钮点击事件
    """
    query = update.callback_query
    select_btn_type = query.data.split()[0]
    chat = query.message.chat
    logger.info("callback query.message.chat ==> %s " % chat)
    logger.info("callback query.data ==> %s " % query.data)
    if select_btn_type == 'node' or select_btn_type == 'spnode' or select_btn_type == 'git':
        try:
            context.bot.edit_message_text(text='```{}```'.format(' ↓↓↓ 任务正在执行 ↓↓↓ \n\n%s' % query.data),
                                          chat_id=query.message.chat_id,
                                          message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
            out_bytes = subprocess.check_output(
                query.data, shell=True, timeout=600, stderr=subprocess.STDOUT)
            out_text = out_bytes.decode('utf-8')
            if len(out_text.split()) > 50:
                context.bot.edit_message_text(text='```{}```'.format(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % query.data),
                                              chat_id=query.message.chat_id,
                                              message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
                log_name = '%sbot_%s_%s.log' % (
                    _logs_dir, select_btn_type, os.path.splitext(query.data.split('/')[-1])[0])
                logger.info('log_name==>' + log_name)

                with open(log_name, 'a+') as wf:
                    wf.write(out_text)

                query.message.reply_document(
                    reply_to_message_id=query.message.message_id, quote=True, document=open(log_name, 'rb'))

            else:
                context.bot.edit_message_text(text='```{}```'.format(
                    helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (query.data, out_text))),
                    chat_id=update.effective_chat.id, message_id=query.message.message_id,
                    parse_mode=ParseMode.MARKDOWN_V2)
        except TimeoutExpired:
            logger.error(' →→→ %s 执行超时 ←←← ' % query.data)
            context.bot.edit_message_text(text='```{}```'.format(' →→→ %s 执行超时 ←←← ' % query.data),
                                          chat_id=query.message.chat_id,
                                          message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
        except:
            context.bot.edit_message_text(text='```{}```'.format(' →→→ %s 执行出错 ←←← ' % query.data),
                                          chat_id=query.message.chat_id,
                                          message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
            raise
    elif select_btn_type.startswith('cl'):
        if select_btn_type == 'cl':
            logger.info(f'crontab_l ==> {query.data.split()[1:]}')
            reply_markup = InlineKeyboardMarkup([
                [InlineKeyboardButton(
                    ' '.join(query.data.split()[1:]), callback_data='pass')],
                [InlineKeyboardButton('⚡️执行', callback_data='cle %s' % ' '.join(query.data.split()[1:])),
                 InlineKeyboardButton('❌删除', callback_data='cld %s' % ' '.join(query.data.split()[1:]))]
            ])
            context.bot.edit_message_text(text='```{}```'.format(' ↓↓↓ 请选择对该定时任务的操作 ↓↓↓ '),
                                          chat_id=query.message.chat_id,
                                          reply_markup=reply_markup, message_id=query.message.message_id,
                                          parse_mode=ParseMode.MARKDOWN_V2)
        elif select_btn_type == 'cle':
            cmd = ' '.join(query.data.split()[6:])
            try:
                context.bot.edit_message_text(text='```{}```'.format(' ↓↓↓ 任务正在执行 ↓↓↓ \n\n%s' % cmd),
                                              chat_id=query.message.chat_id,
                                              message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
                out_bytes = subprocess.check_output(cmd, shell=True, timeout=600,
                                                    stderr=subprocess.STDOUT)
                out_text = out_bytes.decode('utf-8')
                if len(out_text.split()) > 50:

                    context.bot.edit_message_text(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % cmd)),
                        chat_id=update.effective_chat.id, message_id=query.message.message_id,
                        parse_mode=ParseMode.MARKDOWN_V2)

                    log_name = '%sbot_%s_%s.log' % (
                        _logs_dir, select_btn_type, os.path.splitext(cmd.split('/')[-1])[0])

                    with open(log_name, 'a+') as wf:
                        wf.write(out_text)

                    query.message.reply_document(
                        reply_to_message_id=query.message.message_id, quote=True, document=open(log_name, 'rb'))

                else:
                    context.bot.edit_message_text(text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (cmd, out_text))),
                        chat_id=update.effective_chat.id, message_id=query.message.message_id,
                        parse_mode=ParseMode.MARKDOWN_V2)
            except TimeoutExpired:
                logger.error(' →→→ %s 执行超时 ←←← ' % ' '.join(cmd[6:]))
                context.bot.edit_message_text(text='```{}```'.format(' →→→ %s 执行超时 ←←← ' % cmd),
                                              chat_id=query.message.chat_id,
                                              message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
            except:
                context.bot.edit_message_text(text='```{}```'.format(' →→→ %s 执行出错 ←←← ' % cmd),
                                              chat_id=query.message.chat_id,
                                              message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
                raise
        elif select_btn_type == 'cld':
            query.answer(text='删除任务功能暂未实现', show_alert=True)

    elif select_btn_type == 'logs':
        log_file = query.data.split()[-1]
        if log_file == 'clear':
            cmd = 'rm -rf %s*.log' % _logs_dir
            try:
                subprocess.check_output(
                    cmd, shell=True, timeout=600, stderr=subprocess.STDOUT)

                context.bot.edit_message_text(text='```{}```'.format(' →→→ 日志文件已清除 ←←← '),
                                              chat_id=query.message.chat_id,
                                              message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)
            except:
                context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(
                    ' →→→  清除日志执行出错 ←←← ')), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise
        else:
            context.bot.edit_message_text(text='```{}```'.format(' ↓↓↓ 下面为下载的%s文件 ↓↓↓ ' % select_btn_type),
                                          chat_id=query.message.chat_id,
                                          message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)

            query.message.reply_document(reply_to_message_id=query.message.message_id, quote=True,
                                         document=open(log_file, 'rb'))

    else:
        context.bot.edit_message_text(text='```{}```'.format(' →→→ 操作已取消 ←←← '), chat_id=query.message.chat_id,
                                      message_id=query.message.message_id, parse_mode=ParseMode.MARKDOWN_V2)


def get_reply_markup_btn(cmd_type):
    """因为编辑后也可能会需要到重新读取按钮，所以抽出来作为一个方法返回按钮list

    Returns
    -------
    返回一个对应命令类型按钮列表，方便读取
    """
    if cmd_type == 'logs':
        keyboard_line = []
        logs_list = get_dir_file_list(_logs_dir, 'log')
        if (len(logs_list)) > 0:
            file_list = list(set(get_dir_file_list(_logs_dir, 'log')))
            file_list.sort()
            for i in range(math.ceil(len(file_list) / 2)):
                ret = file_list[0:2]
                keyboard_column = []
                for ii in ret:
                    keyboard_column.append(InlineKeyboardButton(
                        ii.split('/')[-1], callback_data='logs %s' % ii))
                    file_list.remove(ii)
                keyboard_line.append(keyboard_column)

            keyboard_line.append([InlineKeyboardButton('清除日志', callback_data='logs clear'),
                                  InlineKeyboardButton('取消操作', callback_data='cancel')])
        else:
            keyboard_line.append([InlineKeyboardButton(
                '未找到相关日志文件', callback_data='cancel')])
        reply_markup = InlineKeyboardMarkup(keyboard_line)
    elif cmd_type == 'crontab_l':
        button_list = list(set(get_crontab_list(cmd_type)))
        logger.info(button_list)
        keyboard_line = []
        if len(button_list) > 0:
            for i in range(math.ceil(len(button_list) / 3)):
                ret = button_list[0:3]
                keyboard_column = []
                for ii in ret:
                    keyboard_column.append(InlineKeyboardButton(
                        ii.split('/')[-1], callback_data=ii))
                    button_list.remove(ii)
                keyboard_line.append(keyboard_column)
            keyboard_line.append([InlineKeyboardButton('取消操作', callback_data='cancel')])
        else:
            keyboard_line.append([InlineKeyboardButton(
                '未从%s获取到任务列表' % crontab_list_file, callback_data='cancel')])
        reply_markup = InlineKeyboardMarkup(keyboard_line)
    elif cmd_type == 'node' or cmd_type == 'spnode':
        button_list = list(set(get_crontab_list(cmd_type)))
        button_list.sort()
        keyboard_line = []
        for i in range(math.ceil(len(button_list) / 2)):
            ret = button_list[0:2]
            keyboard_column = []
            for ii in ret:
                keyboard_column.append(InlineKeyboardButton(
                    ii.split('/')[-1], callback_data=ii))
                button_list.remove(ii)
            keyboard_line.append(keyboard_column)

        keyboard_line.append(
            [InlineKeyboardButton('取消操作', callback_data='cancel')])

        reply_markup = InlineKeyboardMarkup(keyboard_line)
    elif cmd_type == 'git':
        # button_list = list(set(get_crontab_list(cmd_type)))
        # button_list.sort()
        keyboard_line = [[InlineKeyboardButton('git pull', callback_data='git -C %s pull' % _base_dir),
                          InlineKeyboardButton('git reset --hard', callback_data='git -C %s reset --hard' % _base_dir)],
                         [InlineKeyboardButton('取消操作', callback_data='cancel')]]
        # for i in range(math.ceil(len(button_list) / 2)):
        #     ret = button_list[0:2]
        #     keyboard_column = []
        #     for ii in ret:
        #         keyboard_column.append(InlineKeyboardButton(
        #             ii.split('/')[-1], callback_data=ii))
        #         button_list.remove(ii)
        #     keyboard_line.append(keyboard_column)
        # if len(keyboard_line) < 1:
        #     keyboard_line.append(
        #         [InlineKeyboardButton('git pull', callback_data='git -C %s pull' % _base_dir),
        #          InlineKeyboardButton('git reset --hard', callback_data='git -C %s reset --hard' % _base_dir)])
        reply_markup = InlineKeyboardMarkup(keyboard_line)
    else:
        reply_markup = InlineKeyboardMarkup(
            [[InlineKeyboardButton('没找到对的命令操作按钮', callback_data='cancel')]])

    return reply_markup


def get_crontab_list(cmd_type):
    """获取任务列表里面的node相关的定时任务

    Parameters
    ----------
    cmd_type: 是任务的命令类型
    # item_idx: 确定取的需要取之是定任务里面第几个空格后的值作为后面执行指令参数

    Returns
    -------
    返回一个指定命令类型定时任务列表
    """
    button_list = []
    try:
        if cmd_type == 'crontab_l':
            match_cmd = 'crontab -l'
            crontab_list = []
            p = subprocess.Popen(match_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            while p.poll() is None:
                line = p.stdout.readline()
                logger.info(line.decode('utf-8'))
                crontab_list.append(line.decode('utf-8'))
            icnt = 1
            for i in crontab_list:
                logger.info(icnt)
                # if icnt > 100:
                #     break
                if i.startswith('#') or len(i) < 5:
                    logger.info(i)
                    pass
                else:
                    items = i.split('>>')
                    item_sub = items[0].split()
                    logger.info(" ".join(item_sub))
                    if "cd" in item_sub:
                        button_list.append(' '.join(item_sub[item_sub.index("cd"):item_sub.index("cd") + 5]))
                    elif "spnode" in item_sub:
                        button_list.append(' '.join(item_sub[item_sub.index("spnode"):item_sub.index("spnode") + 2]))
                    elif "node" in item_sub:
                        button_list.append(' '.join(item_sub[item_sub.index("node"):item_sub.index("node") + 2]))
                    elif "sh" in item_sub:
                        pass
                        # button_list.append(' '.join(item_sub[item_sub.index("sh"):]))
                    elif "find" in item_sub:
                        pass
                        # button_list.append(' '.join(item_sub[item_sub.index("find"):]))
                    elif "docker_entrypoint.sh" in item_sub:
                        button_list.append(' '.join(
                            item_sub[item_sub.index("docker_entrypoint.sh"):item_sub.index("docker_entrypoint.sh")]))
                    else:
                        pass
                    logger.info(button_list)
                    icnt += 1
        else:
            with open(_docker_dir + crontab_list_file) as lines:
                array = lines.readlines()
                for i in array:
                    i = i.replace('|ts', '').strip('\n')
                    if i.startswith('#') or len(i) < 5:
                        pass
                    else:
                        items = i.split('>>')
                        item_sub = items[0].split()[5:]
                        # logger.info(item_sub[0])
                        if cmd_type.find(item_sub[0]) > -1:
                            if cmd_type == 'spnode':
                                # logger.info(str(' '.join(item_sub)).replace('node','spnode'))
                                button_list.append(str(' '.join(item_sub)).replace('node', 'spnode'))
                            else:
                                button_list.append(' '.join(item_sub))
    except Exception as e:
        logger.warning(f'读取定时任务配置文件 {crontab_list_file} 出错{e}')
    finally:
        logger.info(button_list)
        return button_list


def get_dir_file_list(dir_path, file_type):
    """获取传入的路径下的文件列表

    Parameters
    ----------
    dir_path: 完整的目录路径，不需要最后一个
    file_type: 或者文件的后缀名字

    Returns
    -------
    返回一个完整绝对路径的文件列表，方便读取
    """
    cmd = 'ls %s*.%s' % (dir_path, file_type)
    file_list = []
    try:
        out_bytes = subprocess.check_output(
            cmd, shell=True, timeout=5, stderr=subprocess.STDOUT)
        out_text = out_bytes.decode('utf-8')
        file_list = out_text.split()
    except:
        logger.warning(f'{dir_path}目录下，不存在{file_type}对应的文件')
    finally:
        return file_list


def is_admin(from_user_id):
    if str(admin_id) == str(from_user_id):
        return True
    else:
        return False


class CodeConf(object):
    def __init__(self, bot_id, submit_code, log_name, activity_code, find_split_char):
        self.bot_id = bot_id
        self.submit_code = submit_code
        self.log_name = log_name
        self.activity_code = activity_code
        self.find_split_char = find_split_char

    def get_submit_msg(self):
        code_list = []
        ac = self.activity_code if self.activity_code != "@N" else ""
        try:
            with open("%s%s" % (_logs_dir, self.log_name), 'r') as lines:
                array = lines.readlines()
                for i in array:
                    # print(self.find_split_char)
                    if i.find(self.find_split_char) > -1:
                        code_list.append(i.split(self.find_split_char)[
                                             1].replace('\n', ''))
            if self.activity_code == "@N":
                return '%s %s' % (self.submit_code,
                                  "&".join(list(set(code_list))))
            else:
                return '%s %s %s' % (self.submit_code, ac,
                                     "&".join(list(set(code_list))))
        except:
            return "%s %s活动获取系统日志文件异常，请检查日志文件是否存在" % (self.submit_code, ac)


def gen_long_code(update, context):
    """
    长期活动互助码提交消息生成
    """
    long_code_conf = []
    bot_list = []
    try:
        with open(_share_code_conf, 'r') as lines:
            array = lines.readlines()
            for i in array:
                if i.startswith("long"):
                    bot_list.append(i.split('-')[1])
                    code_conf = CodeConf(
                        i.split('-')[1], i.split('-')[2], i.split('-')[3], i.split('-')[4],
                        i.split('-')[5].replace('\n', ''))
                    long_code_conf.append(code_conf)

        for bot in list(set(bot_list)):
            for cf in long_code_conf:
                if cf.bot_id == bot:
                    print()
                    context.bot.send_message(chat_id=update.effective_chat.id, text=cf.get_submit_msg())
            context.bot.send_message(chat_id=update.effective_chat.id, text="以上为 %s 可以提交的活动互助码" % bot)
    except:
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text="获取互助码消息生成配置文件失败，请检查%s文件是否存在" % _share_code_conf)


def gen_temp_code(update, context):
    """
    短期临时活动互助码提交消息生成
    """
    temp_code_conf = []
    bot_list = []
    try:
        with open(_share_code_conf, 'r') as lines:
            array = lines.readlines()
            for i in array:
                if i.startswith("temp"):
                    bot_list.append(i.split('-')[1])
                    code_conf = CodeConf(
                        i.split('-')[1], i.split('-')[2], i.split('-')[3], i.split('-')[4],
                        i.split('-')[5].replace('\n', ''))
                    temp_code_conf.append(code_conf)

        for bot in list(set(bot_list)):
            for cf in temp_code_conf:
                if cf.bot_id == bot:
                    print()
                    context.bot.send_message(chat_id=update.effective_chat.id, text=cf.get_submit_msg())
            context.bot.send_message(chat_id=update.effective_chat.id, text="以上为 %s 可以提交的短期临时活动互助码" % bot)
    except:
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text="获取互助码消息生成配置文件失败，请检查%s文件是否存在" % _share_code_conf)


def gen_daily_code(update, context):
    """
    每天变化互助码活动提交消息生成
    """
    daily_code_conf = []
    bot_list = []
    try:
        with open(_share_code_conf, 'r') as lines:
            array = lines.readlines()
            for i in array:
                if i.startswith("daily"):
                    bot_list.append(i.split('-')[1])
                    code_conf = CodeConf(
                        i.split('-')[1], i.split('-')[2], i.split('-')[3], i.split('-')[4],
                        i.split('-')[5].replace('\n', ''))
                    daily_code_conf.append(code_conf)

        for bot in list(set(bot_list)):
            for cf in daily_code_conf:
                if cf.bot_id == bot:
                    print()
                    context.bot.send_message(chat_id=update.effective_chat.id, text=cf.get_submit_msg())
            context.bot.send_message(chat_id=update.effective_chat.id, text="以上为 %s 可以提交的每天变化活动互助码" % bot)
    except:
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text="获取互助码消息生成配置文件失败，请检查%s文件是否存在" % _share_code_conf)


def shcmd(update, context):
    """
    执行终端命令，超时时间为60，执行耗时或者不退出的指令会报超时异常
    """
    if is_admin(update.message.from_user.id):
        commands = update.message.text.split()
        commands.remove('/cmd')
        if len(commands) > 0:
            support_cmd = ["echo", "ls", "pwd", "cp", "mv", "ps", "wget", "cat", "sed", "git", "apk", "sh",
                           "docker_entrypoint.sh"]
            if commands[0] in support_cmd:
                sp_cmd = ["sh", "docker_entrypoint.sh"]
                cmd = ' '.join(commands)
                try:
                    # 测试发现 subprocess.check_output 执行shell 脚本文件的时候无法正常执行获取返回结果
                    # 所以 ["sh", "docker_entrypoint.sh"] 指令换为 subprocess.Popen 方法执行
                    out_text = ""
                    if commands[0] in sp_cmd:
                        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                        while p.poll() is None:
                            line = p.stdout.readline()
                            # logger.info(line.decode('utf-8'))
                            out_text = out_text + line.decode('utf-8')
                    else:
                        out_bytes = subprocess.check_output(
                            cmd, shell=True, timeout=60, stderr=subprocess.STDOUT)
                        out_text = out_bytes.decode('utf-8')

                    if len(out_text.split('\n')) > 50:
                        msg = context.bot.sendMessage(text='```{}```'.format(
                            helpers.escape_markdown(' ↓↓↓ %s 执行结果超长,请查看log ↓↓↓' % cmd)),
                            chat_id=update.effective_chat.id,
                            parse_mode=ParseMode.MARKDOWN_V2)
                        log_name = '%sbot_%s_%s.log' % (_logs_dir, 'cmd', commands[0])
                        with open(log_name, 'w') as wf:
                            wf.write(out_text)
                        msg.reply_document(
                            reply_to_message_id=msg.message_id, quote=True, document=open(log_name, 'rb'))
                    else:
                        context.bot.sendMessage(text='```{}```'.format(
                            helpers.escape_markdown(' ↓↓↓ %s 执行结果 ↓↓↓ \n\n%s ' % (cmd, out_text))),
                            chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)

                except TimeoutExpired:
                    context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行超时 ←←← ' % (
                        cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                except Exception as e:
                    context.bot.sendMessage(
                        text='```{}```'.format(helpers.escape_markdown(' →→→ %s 执行出错，请检查确认命令是否正确 ←←← ' % (
                            cmd))), chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                    logger.error(e)
            else:
                update.message.reply_text(
                    text='```{}```'.format(
                        helpers.escape_markdown(
                            f' →→→ {commands[0]}指令不在支持命令范围，请输入其他支持的指令{"|".join(support_cmd)} ←←← ')),
                    parse_mode=ParseMode.MARKDOWN_V2)
        else:
            update.message.reply_text(
                text='```{}```'.format(helpers.escape_markdown(' →→→ 请在/cmd 后写自己需要执行的指的命令  ←←← ')),
                parse_mode=ParseMode.MARKDOWN_V2)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


# getSToken请求获取，s_token用于发送post请求是的必须参数
s_token = ""
# getSToken请求获取，guid,lsid,lstoken用于组装cookies
guid, lsid, lstoken = "", "", ""
# 由上面参数组装生成，getOKLToken函数发送请求需要使用
cookies = ""
# getOKLToken请求获取，token用户生成二维码使用、okl_token用户检查扫码登录结果使用
token, okl_token = "", ""
# 最终获取到的可用的cookie
jd_cookie = ""


def get_jd_cookie(update, context):
    getSToken()
    getOKLToken()

    qr_code_path = genQRCode()
    photo_file = open(qr_code_path, 'rb')
    photo_message = context.bot.send_photo(chat_id=update.effective_chat.id, photo=photo_file,
                                           caption="请使用京东APP扫描二维码获取Cookie")
    photo_file.close()

    return_msg = chekLogin()
    if return_msg == 0:
        context.bot.delete_message(chat_id=update.effective_chat.id, message_id=photo_message.message_id)
        context.bot.send_message(chat_id=update.effective_chat.id, text="获取Cookie成功\n`%s`" % jd_cookie,
                                 parse_mode=ParseMode.MARKDOWN_V2)

    elif return_msg == 21:
        context.bot.delete_message(chat_id=update.effective_chat.id, message_id=photo_message.message_id)
        context.bot.edit_message_text(chat_id=update.effective_chat.id, message_id=photo_message.message_id,
                                      text="二维码已经失效，请重新获取")
    else:
        context.bot.delete_message(chat_id=update.effective_chat.id, message_id=photo_message.message_id)
        context.bot.edit_message_text(chat_id=update.effective_chat.id, message_id=photo_message.message_id,
                                      text=return_msg)


def getSToken():
    time_stamp = int(time.time() * 1000)
    get_url = 'https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%s&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % time_stamp
    get_header = {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-cn',
        'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%s&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % time_stamp,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
        'Host': 'plogin.m.jd.com'
    }
    try:
        resp = requests.get(url=get_url, headers=get_header)
        parseGetRespCookie(resp.headers, resp.json())
        logger.info(resp.headers)
        logger.info(resp.json())
    except Exception as error:
        logger.exception("Get网络请求异常", error)


def parseGetRespCookie(headers, get_resp):
    global s_token
    global cookies
    s_token = get_resp.get('s_token')
    set_cookies = headers.get('set-cookie')
    logger.info(set_cookies)

    guid = re.findall(r"guid=(.+?);", set_cookies)[0]
    lsid = re.findall(r"lsid=(.+?);", set_cookies)[0]
    lstoken = re.findall(r"lstoken=(.+?);", set_cookies)[0]

    cookies = f"guid={guid}; lang=chs; lsid={lsid}; lstoken={lstoken}; "
    logger.info(cookies)


def getOKLToken():
    post_time_stamp = int(time.time() * 1000)
    post_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=%s&v=%s&remember=true' % (
        s_token, post_time_stamp)
    post_data = {
        'lang': 'chs',
        'appid': 300,
        'returnurl': 'https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action' % post_time_stamp,
        'source': 'wq_passport'
    }
    post_header = {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
        'Accept': 'application/json, text/plain, */*',
        'Cookie': cookies,
        'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % post_time_stamp,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
        'Host': 'plogin.m.jd.com',
    }
    try:
        global okl_token
        resp = requests.post(url=post_url, headers=post_header, data=post_data, timeout=20)
        parsePostRespCookie(resp.headers, resp.json())
        logger.info(resp.headers)
    except Exception as error:
        logger.exception("Post网络请求错误", error)


def parsePostRespCookie(headers, data):
    global token
    global okl_token

    token = data.get('token')
    print(headers.get('set-cookie'))
    okl_token = re.findall(r"okl_token=(.+?);", headers.get('set-cookie'))[0]

    logger.info("token:" + token)
    logger.info("okl_token:" + okl_token)


def genQRCode():
    global qr_code_path
    cookie_url = f'https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=%s' % token
    version, level, qr_name = myqr.run(
        words=cookie_url,
        # 扫描二维码后，显示的内容，或是跳转的链接
        version=5,  # 设置容错率
        level='H',  # 控制纠错水平，范围是L、M、Q、H，从左到右依次升高
        picture='/scripts/docker/bot/jd.png',  # 图片所在目录，可以是动图
        colorized=True,  # 黑白(False)还是彩色(True)
        contrast=1.0,  # 用以调节图片的对比度，1.0 表示原始图片。默认为1.0。
        brightness=1.0,  # 用来调节图片的亮度，用法同上。
        save_name='/scripts/docker/genQRCode.png',  # 控制输出文件名，格式可以是 .jpg， .png ，.bmp ，.gif
    )
    return qr_name


def chekLogin():
    expired_time = time.time() + 60 * 3
    while True:
        check_time_stamp = int(time.time() * 1000)
        check_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=%s&ou_state=0&okl_token=%s' % (
            token, okl_token)
        check_data = {
            'lang': 'chs',
            'appid': 300,
            'returnurl': 'https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action' % check_time_stamp,
            'source': 'wq_passport'

        }
        check_header = {
            'Referer': f'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % check_time_stamp,
            'Cookie': cookies,
            'Connection': 'Keep-Alive',
            'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
            'Accept': 'application/json, text/plain, */*',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',

        }
        resp = requests.post(url=check_url, headers=check_header, data=check_data, timeout=30)
        data = resp.json()
        if data.get("errcode") == 0:
            parseJDCookies(resp.headers)
            return data.get("errcode")
        if data.get("errcode") == 21:
            return data.get("errcode")
        if time.time() > expired_time:
            return "超过3分钟未扫码，二维码已过期。"


def parseJDCookies(headers):
    global jd_cookie
    logger.info("扫码登录成功，下面为获取到的用户Cookie。")
    set_cookie = headers.get('Set-Cookie')
    pt_key = re.findall(r"pt_key=(.+?);", set_cookie)[0]
    pt_pin = re.findall(r"pt_pin=(.+?);", set_cookie)[0]
    logger.info(pt_key)
    logger.info(pt_pin)
    jd_cookie = f'pt_key={pt_key};pt_pin={pt_pin};'


def saveFile(update, context):
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        js_file_name = update.message.document.file_name
        if str(js_file_name).endswith(".js"):
            save_path = f"{_base_dir}{js_file_name}"
            try:
                # logger.info(update.message)
                file = context.bot.getFile(update.message.document.file_id)
                file.download(save_path)
                keyboard_line = [[InlineKeyboardButton('node 执行', callback_data='node %s ' % save_path),
                                  InlineKeyboardButton('spnode 执行',
                                                       callback_data='spnode %s' % save_path)],
                                 [InlineKeyboardButton('取消操作', callback_data='cancel')]]

                reply_markup = InlineKeyboardMarkup(keyboard_line)

                update.message.reply_text(
                    text='```{}```'.format(
                        helpers.escape_markdown(' ↓↓↓ %s 上传至/scripts完成，请请选择需要的操作 ↓↓↓ ' % js_file_name)),
                    reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN_V2)

            except Exception as e:
                update.message.reply_text(text='```{}```'.format(
                    helpers.escape_markdown(" →→→ %s js上传至/scripts过程中出错，请重新尝试。 ←←← " % js_file_name)),
                    parse_mode=ParseMode.MARKDOWN_V2)
        else:
            update.message.reply_text(text='```{}```'.format(
                helpers.escape_markdown(" →→→ 抱歉，暂时只开放上传js文件至/scripts目录 ←←← ")),
                parse_mode=ParseMode.MARKDOWN_V2)


def unknown(update, context):
    """回复用户输入不存在的指令
    """
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        spnode_readme = ""
        if "DISABLE_SPNODE" not in os.environ:
            spnode_readme = "/spnode 获取可执行脚本的列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/spnode /scripts/jd_818.js)\n\n" \
                            "使用bot交互+spnode后 后续用户的cookie维护更新只需要更新logs/cookies.list即可\n" \
                            "使用bot交互+spnode后 后续执行脚本命令请使用spnode否者无法使用logs/cookies.list的cookies执行脚本，定时任务也将自动替换为spnode命令执行\n" \
                            "spnode功能概述示例\n\n" \
                            "spnode conc /scripts/jd_bean_change.js 为每个cookie单独执行jd_bean_change脚本（伪并发\n" \
                            "spnode 1 /scripts/jd_bean_change.js 为logs/cookies.list文件里面第一行cookie账户单独执行jd_bean_change脚本\n" \
                            "spnode jd_XXXX /scripts/jd_bean_change.js 为logs/cookies.list文件里面pt_pin=jd_XXXX的cookie账户单独执行jd_bean_change脚本\n" \
                            "spnode /scripts/jd_bean_change.js 为logs/cookies.list所有cookies账户一起执行jd_bean_change脚本\n" \
                            "请仔细阅读并理解上面的内容，使用bot交互默认开启spnode指令功能功能。\n" \
                            "如需____停用___请配置环境变量 -DISABLE_SPNODE=True"
        update.message.reply_text(text="⚠️ 您输入了一个错误的指令，请参考说明使用\n" \
                                       "\n" \
                                       "/start 开始并获取指令说明\n" \
                                       "/node 获取可执行脚本的列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/node /scripts/jd_818.js) \n" \
                                       "/git 获取可执行git指令列表，选择对应的按钮执行。(拓展使用：运行指定路径脚本，例：/git -C /scripts/ pull)\n" \
                                       "/logs 获取logs下的日志文件列表，选择对应名字可以下载日志文件\n" \
                                       "/env 获取系统环境变量列表。(拓展使用：设置系统环境变量，例：/env export JD_DEBUG=true，环境变量只针对当前bot进程生效) \n" \
                                       "/cmd 执行执行命令。参考：/cmd ls -l 涉及目录文件操作请使用绝对路径,部分shell命令开放使用\n" \
                                       "/crontab 查看定时任务。\n" \
                                       "/eikooc_dj_teg 获取cookie。\n" \
                                       "/gen_long_code 长期活动互助码提交消息生成\n" \
                                       "/gen_temp_code 短期临时活动互助码提交消息生成\n" \
                                       "/gen_daily_code 每天变化互助码活动提交消息生成\n\n%s" % spnode_readme,
                                  parse_mode=ParseMode.HTML)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)
    context.bot.send_message(
        'Update "%s" caused error "%s"', update, context.error)


def main():
    global admin_id, bot_token, crontab_list_file

    if 'TG_BOT_TOKEN' in os.environ:
        bot_token = os.getenv('TG_BOT_TOKEN')

    if 'TG_USER_ID' in os.environ:
        admin_id = os.getenv('TG_USER_ID')

    
    crontab_list_file = 'merged_list_file.sh'

    logger.info('CRONTAB_LIST_FILE=' + crontab_list_file)

    # 创建更新程序并参数为你Bot的TOKEN。
    updater = Updater(bot_token, use_context=True)

    # 获取调度程序来注册处理程序
    dp = updater.dispatcher

    # 通过 start 函数 响应 '/start' 命令
    dp.add_handler(CommandHandler('start', start))

    # 通过 start 函数 响应 '/help' 命令
    dp.add_handler(CommandHandler('help', start))

    # 通过 node 函数 响应 '/node' 命令
    dp.add_handler(CommandHandler('node', node))

    # 通过 node 函数 响应 '/spnode' 命令
    dp.add_handler(CommandHandler('spnode', spnode))

    # 通过 git 函数 响应 '/git' 命令
    dp.add_handler(CommandHandler('git', git))

    # 通过 crontab 函数 响应 '/crontab' 命令
    dp.add_handler(CommandHandler('crontab', crontab))

    # 通过 logs 函数 响应 '/logs' 命令
    dp.add_handler(CommandHandler('logs', logs))

    # 通过 cmd 函数 响应 '/cmd' 命令
    dp.add_handler(CommandHandler('cmd', shcmd))

    # 通过 callback_run 函数 响应相关按钮命令
    dp.add_handler(CallbackQueryHandler(callback_run))

    # 通过 env 函数 响应 '/env' 命令
    dp.add_handler(CommandHandler('env', env))

    # 通过 gen_long_code 函数 响应 '/gen_long_code' 命令
    dp.add_handler(CommandHandler('gen_long_code', gen_long_code))

    # 通过 gen_temp_code 函数 响应 '/gen_temp_code' 命令
    dp.add_handler(CommandHandler('gen_temp_code', gen_temp_code))

    # 通过 gen_daily_code 函数 响应 '/gen_daily_code' 命令
    dp.add_handler(CommandHandler('gen_daily_code', gen_daily_code))

    # 通过 get_jd_cookie 函数 响应 '/eikooc_dj_teg' 命令 #别问为啥这么写，有意为之的
    dp.add_handler(CommandHandler('eikooc_dj_teg', get_jd_cookie))

    # 文件监听
    dp.add_handler(MessageHandler(Filters.document, saveFile))

    # 没找到对应指令
    dp.add_handler(MessageHandler(Filters.command, unknown))

    # 响应普通文本消息
    # dp.add_handler(MessageHandler(Filters.text, resp_text))

    dp.add_error_handler(error)

    updater.start_polling()
    updater.idle()


# 生成依赖安装列表
# pip3 freeze > requirements.txt
# 或者使用pipreqs
# pip3 install pipreqs
# 在当前目录生成
# pipreqs . --encoding=utf8 --force
# 使用requirements.txt安装依赖
# pip3 install -r requirements.txt
if __name__ == '__main__':
    main()
