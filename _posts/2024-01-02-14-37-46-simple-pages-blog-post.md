---
title: "Simple Github pages blog post"
date: 2024-01-02 14:37:46
---
## Overview
This post summarises a simple workflow to add new posts to an existing Github pages-based Jekyll formatted blog. For further reading on the initial setup see [Further Reading](#further-reading)
## How-to
1. Create a new post file
Create the post file with an appropriately time-stamped name. Assuming our repository is checked out at `~/repos/github-pages/`:
```
$ touch ~/repos/github-pages/$(date -I)-$(date +%H-%M-%S)-simple-pages-blog-post.md
```
2. Add the contents including any requisite [FrontMatter](https://jekyllrb.com/docs/front-matter/)
Edit the new post:
```
$ vim ~/repos/github-pages/2024-01-02-14-37-46-simple-pages-blog-post.md
```
Add the FrontMatter, for example:
```
---
title: "Simple Github pages blog post"
date: 2024-01-02 14:37:46
---
```
Add the rest of the blog post after the FrontMatter using standard [Github markdown](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).

For example, [this entire blog post's markdown can be viewed here](https://github.com/wmcdonald404/github-pages/blob/main/_posts/2024-01-02-14-37-46-simple-pages-blog-post.md#further-reading).

3. Verify `git status`, `git add` the new content, `git commit` the new post and `git push` to the remote repository

Check the current Git source control state:
```
wmcdonald@fedora:~/repos/github-pages$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        _posts/2024-01-02-14-37-46-simple-pages-blog-post.md

no changes added to commit (use "git add" and/or "git commit -a")
```
Add the new content in order to stage the new changes:
```
wmcdonald@fedora:~/repos/github-pages$ git add _posts/
```
Validate the new Git state:
```
wmcdonald@fedora:~/repos/github-pages$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   _posts/2024-01-02-14-37-46-simple-pages-blog-post.md
```
Commit the new content:
```
wmcdonald@fedora:~/repos/github-pages$ git commit -m '- Add new blog post describing simple workflow to add new post.'
[main 0126586] - Add new blog post describing simple workflow to add new post.
 1 file changed, 64 insertions(+)
 create mode 100644 _posts/2024-01-02-14-37-46-simple-pages-blog-post.md
```
Push to the remote to trigger a workflow:
```
wmcdonald@fedora:~/repos/github-pages$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

wmcdonald@fedora:~/repos/github-pages$ git push
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 8 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 1.79 KiB | 1.79 MiB/s, done.
Total 8 (delta 3), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (3/3), completed with 1 local object.
To https://github.com/wmcdonald404/github-pages.git
   7609736..5dd04aa  main -> main
```
4. Check that the new post has been generated
Verify that the new post is visible as a **Post** on your [Github page](https://wmcdonald404.github.io/github-pages/).
Navigate to [your new post](https://wmcdonald404.github.io/github-pages/2024/01/02/14-37-46-simple-pages-blog-post.html) to verify its publication.



## Further reading
- https://github.com/skills/github-pages
- https://chadbaldwin.net/2021/03/14/how-to-build-a-sql-blog.html
- https://tomcam.github.io/least-github-pages/