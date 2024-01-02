---
title: "Simple Github pages blog post"
date: 2024-01-02T14:37:46
---
## Overview
This post summarises a simple workflow to add new posts to an existing Github pages-based Jekyll formatted blog. For further reading on the initial setup see [Further Reading]()
## How-to
1. Create a new post file
Create the post file with an appropriately time-stamped name. Assuming our repository is checked out at `~/repos/github-pages/`:
```
$ touch ~/repos/github-pages/$(date -Isec)-simple-pages-blog-post.md
```
2. Add the contents including any requisite [FrontMatter](https://jekyllrb.com/docs/front-matter/)
Edit the new post:
```
$ vim ~/repos/github-pages/2024-01-02T14:37:46+00:00-simple-pages-blog-post.md
```
Add the FrontMatter, for example:
```
---
title: "Simple Github pages blog post"
date: 2024-01-02T14:37:46
---
```
Add the rest of the blog post after the FrontMatter using standard [Github markdown](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax).

3. Verify `git status`, `git add` the new content, `git commit` the new post and `git push` to the remote repository

Check the current Git source control state:
```
wmcdonald@fedora:~/repos/github-pages$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        _posts/2024-01-02T14:37:46+00:00-simple-pages-blog-post.md

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
        new file:   _posts/2024-01-02T14:37:46+00:00-simple-pages-blog-post.md
```
Commit the new content:
```
wmcdonald@fedora:~/repos/github-pages$ git commit -m '- Add new blog post describing simple workflow to add new post.'
[main 0126586] - Add new blog post describing simple workflow to add new post.
 1 file changed, 64 insertions(+)
 create mode 100644 _posts/2024-01-02T14:37:46+00:00-simple-pages-blog-post.md
```

Push to the remote to trigger a workflow

4. Check that the new post has been generated




## Further reading
- https://github.com/skills/github-pages
- https://chadbaldwin.net/2021/03/14/how-to-build-a-sql-blog.html
- https://tomcam.github.io/least-github-pages/
