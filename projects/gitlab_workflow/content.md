# Workflow
## Workflow Overview
* 基本原则：master为保护分支，不直接在master上进行代码修改和提交。
* 日常开发，从master分支上checkout一个feature分支进行开发，检查通过后，将feature分支合并到master，最后删除feature分支。

## Workflow Overview

![](workflow.png)

## 克隆仓库

```
$ git clone git@10.8.2.38:pmo/test.git
```

## 新建工作分支

* 基于master分支最新的代码创建工作分支

```
$ git checkout master
$ git pull --rebase
$ git checkout -b bugfix_xxx
$ git checkout -b feature_xxx
$ git checkout -b refactor_xxx
```

## 提交修改

* 提交前检查

```
$ git status
$ git diff
$ git add file1 file2
$ git commit
$ git commit --fixup=commit-id
```

## 整理提交

```
$ git log
$ git show --stat commit-id
$ git show commit-id
$ git commit --amend
$ git rebase -i commit-id^
```

## 推送工作分支

```
$ git fetch origin
$ git rebase origin/master
$ git push origin bugfix_xxx
$ git push origin feature_xxx
$ git push origin refactor_xxx
```

## 创建合并请求

![](create_merge_request.png)

## 创建合并请求

![](edit_merge_request.png)

## 代码审查

![](code_review.png)

## 执行合并

![](merge_request.png)

# Git Tips
## Git集成Beyond Compare 
* 安装Beyond Compare4
* 配置Git（假设BC安装路径为`C:\Program Files\Beyond Compare 4`）

```
$ git config --global diff.tool bc4
$ git config --global difftool.prompt false
$ git config --global difftool.bc4.cmd '"C:\Program Files\Beyond Compare 4\BCompare.exe" "$LOCAL" "$REMOTE"'
$ 
$ git config --global merge.tool bc4
$ git config --global mergetool.prompt false
$ git config --global mergetool.bc4.cmd '"C:\Program Files\Beyond Compare 4\BCompare.exe" "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'
$ git config --global mergetool.bc4.trustexitcode true
```

## 提交日志图形化

```
$ git log --graph --decorate --oneline
$ git log --graph --decorate --oneline --all
```

![](git_graph.png)

* 在`~/.gitconfig`中添加如下设置，然后可以直接使用`git l`命令

```
[alias]
    l = log --decorate --graph --pretty=format:'%Cred%h%Creset 
 -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
 --abbrev-commit --date=relative
```

## 修改提交日志
* 修改之前提交的日志
* 已经merge到远程仓库master分支的提交不允许修改
* 修改最近一次提交使用如下命令

```
$ git commit --amend # 修改最近一次提交
```

## 补充提交

* 将本次提交作为之前提交的补充
* 已经merge到远程仓库master分支的提交不允许修改

```
$ git commit --fixup=commit-id # commit-id为补充到的目的SHA
$ git rebase -i commit-id^ --autosquash
```

## 合并提交
* 将多个提交合并为单个提交
* 已经merge到远程仓库master分支的提交不允许修改
* 执行如下命令后，将需要合并的提交集中放置在一起，将pick改为squash或s

```
$ git rebase -i commit-id^ # commit-id为需要合并的最早一次提交的SHA
```

# 提交规范
## 提交的格式
* Header: commit的标题，不能太长，避免自动换行, 必需的，不可省略
* Body: 是对本次 commit 的详细描述，可以分成多行,可以省略 
* Footer: 附加说明，可以省略 

```
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

## Header
* type: 用于说明 commit 的类别，必需，不可省略 
* scope: 用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同，可省略
* subject: commit 目的的简短描述，不超过50个字符，必需，不可省略

## Header -- type
* feat：新功能（feature）
* fix：修补bug
* docs：文档（documentation）
* style： 格式（不影响代码运行的变动）
* refactor：重构（即不是新增功能，也不是修改bug的代码变动）
* test：增加测试
* chore：构建过程或辅助工具的变动
* revert：撤销以前的commit 

## Header -- subject
* 以动词开头，使用第一人称现在时，比如change，而不是changed或changes
* 第一个字母小写
* 结尾不加句号（.）

## Body
* Body 部分是对本次 commit 的详细描述，可以分成多行。
* 使用第一人称现在时，比如使用change而不是changed或changes。
* 应该说明代码变动的动机，以及与以前行为的对比。

## Footer
* 如果当前 commit 针对某个issue，那么可以在 Footer 部分关闭这个 issue 。

```
Closes #234
```
---

## 一个范例

```
docs(document): 标题50个字符以内，描述主要变更内容

更详细的说明文本，建议72个字符以内。 需要描述的信息包括:

* 变更的原因，可能是用来修复一个bug，增加一个feature，提升性能、可靠性、稳定性等等
* 他如何解决这个问题? 具体描述解决问题的步骤
* 是否存在副作用、风险? 

如果需要的化可以添加一个链接到issue地址或者其它文档，或者关闭某个issue。
```

## The End

![](question.png)
