#!/usr/bin/python
# -*- encoding: utf-8 -*-

import os
import sys
import re

class_path = sys.argv[1]
Scripts_path = './.style_temp/'

DEBUG = 0

def getpwd():
    pwd = sys.path[0]
    if os.path.isfile(pwd):
        pwd = os.path.dirname(pwd)
    return pwd

def didNotIncludedInNSString(match, eachline, is_multiple_line_string):
    localline = eachline
    leftPos = match.start()
    rightPos = match.end()

    if eachline.startswith("+#define"):
        return False


    # filter \" char
    localline = localline.replace(r'\"', '')

    # 处理以"打头的行,这是多行字符串引起的
    if is_multiple_line_string:
        list_line = list(localline)
        list_line.insert(localline.find('"'), '@')
        localline = "".join(list_line)
        leftPos += 1
        rightPos += 1

    leftStr = localline[:leftPos]
    rightStr = localline[rightPos:]
    leftFind = leftStr.rfind('"')
    rightFind = rightStr.find('"')

    if leftFind != -1 and leftStr[leftFind - 1] == '@' and rightFind != -1:
        return False

    return True


def is_comment_searched(offset, changed):
    former_num = offset - 1
    former_line = changed[former_num]
    if former_line.startswith("@@"):
        return False
    elif re.search(r'(\+)?\s*(///|\*/)', former_line):
        return True
    elif former_line.startswith("-"):
        return is_comment_searched(former_num, changed)
    else:
        return False


def main():
    if (DEBUG == 1):
        return 0;
    reload(sys)
    sys.setdefaultencoding("UTF-8")

    isExists = os.path.exists(Scripts_path)
    if not isExists:
        os.mkdir(Scripts_path)
        os.system("touch " + Scripts_path + "changed_line_only_m_file")
        os.system("touch " + Scripts_path + "git_diff.diff")
        os.system("touch " + Scripts_path + "git_lines_count")
        os.system("touch " + Scripts_path + "git_diff_m_file.diff")
        os.system("touch " + Scripts_path + "git_diff_h_file.diff")


    # only search modified h and m files
    ori_lines_only_m_file = os.popen('git diff --cached --name-only ' + class_path + ' | xargs -I {} find {} -name \'*.m\' -o -name \'*.mm\' | xargs -I {} git diff --cached {}')
    ori_lines_only_h_file = os.popen('git diff --cached --name-only ' + class_path + ' | xargs -I {} find {} -name \'*.h\' | xargs -I {} git diff --cached {}')
    changed_line_only_m_file = ori_lines_only_m_file.readlines()
    changed_line_only_h_file = ori_lines_only_h_file.readlines()

    fo_m_file = open(Scripts_path + 'git_diff_m_file.diff', 'w+')
    fo_h_file = open(Scripts_path + 'git_diff_h_file.diff', 'w+')
    try:
        fo_m_file.writelines(changed_line_only_m_file)
        fo_h_file.writelines(changed_line_only_h_file)

    finally:
        fo_m_file.close()
        fo_h_file.close()

    is_error_detected_m = False
    is_error_detected_h = False

#对m文件进行检查###################################################################################################
    for (offset, eachline) in enumerate(changed_line_only_m_file):
        eachline_remove_blank = eachline.replace(" ", "")
        if eachline[0] != '+':
            # not modified lines
            continue

        # even comment line's length can not exceed 120.
        # if len(eachline) > 122 and not eachline.startswith("+++") and not eachline.startswith("---") and not eachline.endswith("// avoid 120\n"):
        #     encoded_line = eachline.decode('utf-8')
        #     if len(encoded_line) > 122:
        #         # line length > 122 (one more '+')
        #         print '此行代码@%d行, 长度@%d : %s' % ((offset + 1), (len(encoded_line) - 1), eachline)
        #         print('error: 代码行长度超过120\n')
        #         is_error_detected_m = True
        #         continue

        regex = r'\s'
        match = re.compile(regex)
        new_line, num = match.subn('', eachline)
        is_multiple_line_string = False
        if len(new_line) > 1 and new_line[1] == '"':
            is_multiple_line_string = True
        if len(new_line) > 2 and new_line[1:3] == '//':
            # ignore comment line
            continue

        # match = re.search(r'(if|while|for|switch|@property)\(', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     print '错误行号:%d' % (offset + 1)
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: if,while,for,switch,@property后面必须带空格\n')
        #     is_error_detected_m = True
        #     continue

        match1 = re.search(r'\{//', eachline)
        match2 = re.search(r'\}//', eachline)
        match3 = re.search(r'@[{}]\w+', eachline_remove_blank)
        match4 = re.match(r'^\+\s*.*@+\{[a-zA-Z0-9_\:\,\ \@\"};]+\s*.*$', eachline)

        if match1 and didNotIncludedInNSString(match1, eachline, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号当前行不得写注释\n')
            is_error_detected_m = True
            continue

        if match2 and didNotIncludedInNSString(match2, eachline, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号当前行不得写注释\n')
            is_error_detected_m = True
            continue

        if match3 and not match4 and didNotIncludedInNSString(match3, eachline_remove_blank, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号必须另起一行,且独立\n')
            is_error_detected_m = True
            continue

        # "+ xxxxx {" lines are error
        match1 = re.match(r'^\+.*\{\s*$', eachline)
        match2 = re.match(r'^\+\s*\{\s*$', eachline)
        match3 = re.match(r'^\+.*\^\s*\{\s*$', eachline)
        match4 = re.match(r'^\+.*\^\s*\(.*\)\s*\{\s*$', eachline)
        match5 = re.match(r'^\+.*\^.*[a-zA-Z\s\*]+\(.*\)\s*\{\s*$', eachline)
        match6 = re.match(r'^\+.*\^.*[a-zA-Z\s\*]+\s*\{\s*$', eachline)
        match7 = re.match(r'^\+.*\=\s\(\{\s*\n$', eachline)
        match8 = re.match(r'^\+\s*.*@+\{[a-zA-Z0-9_\:\,\ \@\"};]+\s*.*$', eachline)
        if match1 and not match2 and not match3 and not match4 and not match5 and not match6 and not match7 and not match8:
            if match1 and didNotIncludedInNSString(match1, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 左大括号必须另起一行\n')
                is_error_detected_m = True
                continue

        # "+ xxxx }\s.*else" lines are error
        match = re.search(r'\}\s*else', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: else 必须另起一行\n')
            is_error_detected_m = True
            continue

        # "( " lines are error
        match = re.search(r'\(\s+', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\(\s+).)+?"', eachline)):
                #not very precise, but enough
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 左圆括号后面不能带空格\n')
                is_error_detected_m = True
                continue

        # " )" lines are error
        match = re.search(r'\s+\)', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\s+\)).)+?"', eachline)):
                #not very precise, but enough
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 右圆括号前面不能带空格\n')
                is_error_detected_m = True
                continue

        # "]blahblah" lines are error
        match = re.search(r'\][a-zA-Z0-9]', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\][a-zA-Z0-9]).)+?"', eachline)):
                #not very precise, but enough
                print ('错误行号: %d' % (offset + 1))
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 方法链式调用必须加空格\n')
                is_error_detected_m = True
                continue

        # match = re.search(r'(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)\S+', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     if not re.search(r'".*"', eachline) or \
        #     (re.search(r'".*"', eachline) and re.search(r'"(?:(?!(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)\S+).)+?"', eachline)):
        #         #not very precise, but enough
        #         print ('错误行号: %d' % (offset + 1))
        #         print('error: 操作符右边必须带空格\n')
        #         is_error_detected_m = True
        #         continue

        # match = re.search(r'\S+(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     if not re.search(r'".*"', eachline) or \
        #     (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\S+(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)).)+?"', eachline)):
        #         #not very precise, but enough
        #         print ('错误行号: %d' % (offset + 1))
        #         print('error: 操作符左边必须带空格\n')
        #         is_error_detected_m = True
        #         continue

        match = re.search(r'(=@|=[a-zA-Z0-9]|[a-zA-Z0-9]=)', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!(=@|=[a-zA-Z0-9]|[a-zA-Z0-9]=)).)+?"', eachline)):
                #not very precise, but enough
                print ('错误行号: %d' % (offset + 1))
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 等号两边必须带空格\n')
                is_error_detected_m = True
                continue

        # if re.match(r'^\s*[-+]\([\w\s*]+\).*$', eachline[1:]):
        #     print ('错误行号: %d' % (offset + 1))
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: 方法声明-+后面必须加空格\n')
        #     is_error_detected_m = True
        #     continue

        # if re.match(r'^\s*[-+][ ]\([\w\s*]+\)[ ].*$', eachline[1:]):
        #     print ('错误行号: %d' % (offset + 1))
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: 方法声明返回值括号后面不能加空格\n')
        #     is_error_detected_m = True
        #     continue

        if re.match(r'^\s*typedef (NS_OPTIONS|NS_ENUM)\s*\(', eachline[1:]):
            if not is_comment_searched(offset, changed_line_only_m_file):
                print '错误行号:%d' % (offset + 1)
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 新添加的接口typedef必须编写相应文档，*/ 详细参考文档\n')
                is_error_detected_m = True
                continue


        # 检查m文件中的属性是否以m打头
        # if eachline[1:].startswith('@property') and eachline[1:].find('readwrite') == -1:
        #     eachline = eachline[:eachline.find(';')]
        #     splitList = eachline[1:].split(' ')
        #     last = splitList[-1]
        #     is_error = True
        #     if last.startswith('*'):
        #         if last[1] == 'm' and last[2].isupper():
        #             is_error = False
        #     elif (last.startswith('*') == False and last != ''):
        #         if last[0] == 'm' and last[1].isupper():
        #             is_error = False

        #     if is_error:
        #         print ('错误行号: %d' % (offset + 1))
        #         print '错误行@%d: %s' % ((offset + 1), eachline)
        #         print ('error:私有属性必须以m打头\n')
        #         is_error_detected_m = True
        #         continue

#对h文件进行检查###################################################################################################
    for (offset, eachline) in enumerate(changed_line_only_h_file):
        eachline_remove_blank = eachline.replace(" ", "")
        if eachline[0] != '+':
            # not modified lines
            continue

        # even comment line's length can not exceed 120.
        # if len(eachline) > 122 and not eachline.startswith("+++") and not eachline.startswith("---") and not eachline.endswith("// avoid 120\n") and not eachline.startswith("+#define "):
        #     encoded_line = eachline.decode('utf-8')
        #     if len(encoded_line) > 122:
        #         # line length > 122 (one more '+')
        #         print '此行代码@%d行, 长度@%d : %s' % ((offset + 1), (len(encoded_line) - 1), eachline)
        #         print('error: 代码行长度超过120\n')
        #         is_error_detected_h = True
        #         continue

        regex = r'\s'
        match = re.compile(regex)
        new_line, num = match.subn('', eachline)
        is_multiple_line_string = False
        if len(new_line) > 1 and new_line[1] == '"':
            is_multiple_line_string = True
        if len(new_line) > 2 and new_line[1:3] == '//':
            # ignore comment line
            continue

        # match = re.search(r'(if|while|for|switch|@property)\(', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     print '错误行号:%d' % (offset + 1)
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: if,while,for,switch,@property后面必须带空格\n')
        #     is_error_detected_h = True
        #     continue

        match1 = re.search(r'\{//', eachline)
        match2 = re.search(r'\}//', eachline)
        match3 = re.search(r'[{}]\w+', eachline_remove_blank)

        if match1 and didNotIncludedInNSString(match1, eachline, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号当前行不得写注释\n')
            is_error_detected_h = True
            continue

        if match2 and didNotIncludedInNSString(match2, eachline, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号当前行不得写注释\n')
            is_error_detected_h = True
            continue

        if match3 and didNotIncludedInNSString(match3, eachline_remove_blank, is_multiple_line_string):
            print '错误行号:%d' % (offset + 1)
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: 大括号必须另起一行,且独立\n')
            is_error_detected_h = True
            continue

        # @param @return empty commit
        match0 = re.match(r'^\+\s*\*\s*.*#>\s*$', eachline)
        match1 = re.match(r'^\+\s*\*\s*@param\s*$', eachline)
        match2 = re.match(r'^\+\s*\*\s*@param\s*[a-zA-Z0-9_]+\s*$', eachline)
        match3 = re.match(r'^\+\s*\*\s*@return\s*$', eachline)

        if match0:
            if didNotIncludedInNSString(match0, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 注释中包含冗余占位符0\n')
                is_error_detected_h = True
                continue

        if match1:
            if didNotIncludedInNSString(match1, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 注释中包含冗余占位符1\n')
                is_error_detected_h = True
                continue

        if match2:
            if didNotIncludedInNSString(match2, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 注释中包含冗余占位符2\n')
                is_error_detected_h = True
                continue

        if match3:
            if didNotIncludedInNSString(match3, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 注释中包含冗余占位符3\n')
                is_error_detected_h = True
                continue


        # "+ xxxxx {" lines are error
        match1 = re.match(r'^\+.*\{\s*$', eachline)
        match2 = re.match(r'^\+\s*\{\s*$', eachline)
        if match1 and not match2:
            if match1 and didNotIncludedInNSString(match1, eachline, is_multiple_line_string):
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 左大括号必须另起一行\n')
                is_error_detected_h = True
                continue

        # "+ xxxx }\s.*else" lines are error
        match = re.search(r'\}\s*else', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            print '错误行@%d: %s' % ((offset + 1), eachline)
            print('error: else 必须另起一行\n')
            is_error_detected_h = True
            continue

        # "( " lines are error
        match = re.search(r'\(\s+', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\(\s+).)+?"', eachline)):
                #not very precise, but enough
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 左圆括号后面不能带空格\n')
                is_error_detected_h = True
                continue

        # " )" lines are error
        match = re.search(r'\s+\)', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\s+\)).)+?"', eachline)):
                #not very precise, but enough
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 右圆括号前面不能带空格\n')
                is_error_detected_h = True
                continue

        # "]blahblah" lines are error
        match = re.search(r'\][a-zA-Z0-9]', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\][a-zA-Z0-9]).)+?"', eachline)):
                #not very precise, but enough
                print ('错误行号: %d' % (offset + 1))
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 方法链式调用必须加空格\n')
                is_error_detected_h = True
                continue

        # match = re.search(r'(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)\S+', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     if not re.search(r'".*"', eachline) or \
        #     (re.search(r'".*"', eachline) and re.search(r'"(?:(?!(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)\S+).)+?"', eachline)):
        #         #not very precise, but enough
        #         print ('错误行号: %d' % (offset + 1))
        #         print('error: 操作符右边必须带空格\n')
        #         is_error_detected_h = True
        #         continue

        # match = re.search(r'\S+(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)', eachline)
        # if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
        #     if not re.search(r'".*"', eachline) or \
        #     (re.search(r'".*"', eachline) and re.search(r'"(?:(?!\S+(\|\||&&|<<|>>|\-=|\+=|\*=|/=|!=|==|<=|>=)).)+?"', eachline)):
        #         #not very precise, but enough
        #         print ('错误行号: %d' % (offset + 1))
        #         print('error: 操作符左边必须带空格\n')
        #         is_error_detected_h = True
        #         continue

        match = re.search(r'(=@|=[a-zA-Z0-9]|[a-zA-Z0-9]=)', eachline)
        if match and didNotIncludedInNSString(match, eachline, is_multiple_line_string):
            if not re.search(r'".*"', eachline) or \
            (re.search(r'".*"', eachline) and re.search(r'"(?:(?!(=@|=[a-zA-Z0-9]|[a-zA-Z0-9]=)).)+?"', eachline)):
                #not very precise, but enough
                print ('错误行号: %d' % (offset + 1))
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 等号两边必须带空格\n')
                is_error_detected_h = True
                continue

        # if re.match(r'^\s*[-+]\([\w\s*]+\).*$', eachline[1:]):
        #     print ('错误行号: %d' % (offset + 1))
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: 方法声明-+后面必须加空格\n')
        #     is_error_detected_h = True
        #     continue

        # if re.match(r'^\s*[-+][ ]\([\w\s*]+\)[ ].*$', eachline[1:]):
        #     print ('错误行号: %d' % (offset + 1))
        #     print '错误行@%d: %s' % ((offset + 1), eachline)
        #     print('error: 方法声明返回值括号后面不能加空格\n')
        #     is_error_detected_h = True
        #     continue

        if re.match(r'\+\s*(-|\+)\s*\([^)]+\).*$', eachline):
            if not is_comment_searched(offset, changed_line_only_h_file):
                print '错误行号:%d' % (offset + 1)
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 新添加的接口函数必须编写相应文档，*/ 详细参考文档\n')
                is_error_detected_h = True
                continue

        if re.match(r'\+[ \t]*\@interface[ \t]+.*$', eachline):
            if not is_comment_searched(offset, changed_line_only_h_file):
                print '错误行号:%d' % (offset + 1)
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 新添加的接口interface必须编写相应文档，*/ 详细参考文档\n')
                is_error_detected_h = True
                continue

        if re.match(r'\+[ \t]*\@protocol[ \t]+[a-zA-Z0-9_<>*]+[ \t\n]*$', eachline):
            if not is_comment_searched(offset, changed_line_only_h_file):
                print '错误行号:%d' % (offset + 1)
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 新添加的接口protocol必须编写相应文档，*/ 详细参考文档\n')
                is_error_detected_h = True
                continue

        if re.match(r'^\s*typedef (NS_OPTIONS|NS_ENUM)\s*\(', eachline[1:]):
            if not is_comment_searched(offset, changed_line_only_h_file):
                print '错误行号:%d' % (offset + 1)
                print '错误行@%d: %s' % ((offset + 1), eachline)
                print('error: 新添加的接口typedef必须编写相应文档，*/ 详细参考文档\n')
                is_error_detected_h = True
                continue

        # if re.match(r'\+\@property\w*', eachline):
        #     if not is_comment_searched(offset,changed_line_only_h_file):
        #         print '错误行号:%d' % (offset + 1)
        #         print('error: 新添加的接口property必须编写相应文档，*/ 详细参考文档\n')
        #         is_error_detected_h = True
        #         continue

    if is_error_detected_m and is_error_detected_h:
        print "diff文件已写入 " + Scripts_path + "/git_diff_h_file.diff以及git_diff_m_file.diff, 请核查修正后重新提交"
        return 1
    elif is_error_detected_m and not is_error_detected_h:
        print "diff文件已写入 " + Scripts_path + "/git_diff_m_file.diff, 请核查修正后重新提交"
        return 1
    elif not is_error_detected_m and is_error_detected_h:
        print "diff文件已写入 " + Scripts_path + "/git_diff_h_file.diff, 请核查修正后重新提交"
        return 1
    else:
        fo_m_file = open(Scripts_path + 'git_diff_m_file.diff', 'w+')
        fo_h_file = open(Scripts_path + 'git_diff_h_file.diff', 'w+')
        try:
            fo_m_file.truncate()
            fo_h_file.truncate()

        finally:
            fo_m_file.close()
            fo_h_file.close()
        return 0

if __name__ == "__main__":
    sys.exit(main())
