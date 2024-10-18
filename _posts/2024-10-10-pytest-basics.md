---
title: "Pytest Basics"
date: 2024-10-10 10-35-00
tags:
- python
- testing
---

## Overview
I recently had to help some clients learn the basics of Pytest, and in order to do so I obviously had to learn Pytest first myself. This is just to capture some of the basics, some examples, and some recommendations and references acquired as part of the process.

## Recommendations
If there's one primary recommendation, it would be to buy and read [Python Testing with pytest, Second Edition](https://pragprog.com/titles/bopytest2/python-testing-with-pytest-second-edition/) by [Brian Okken](https://github.com/okken).

For UK readers: [hive.co.uk - Python Testing with pytest : Simple, Rapid, Effective, and Scalable](https://www.hive.co.uk/Product/Brian-Okken/Python-Testing-with-pytest--Simple-Rapid-Effective-and-Scalable/26979929).

I'll include a number of other useful online resources, but the **Python Testing with pytest** book will save most people the time spent piecing together and digesting these into a single, well-paced learning experience.

## Examples

<script src="https://gist.github.com/wmcdonald404/669a2377ef929c935f0236210e8b6960.js"></script>

## References
The core docs for Pytest are very good but often a primer / how-to helps, the resources below have all helped clarify many of the aspects of Pytest. 

### Pytest Core Docs
- [Full pytest documentation](https://docs.pytest.org/en/7.1.x/contents.html)

### Pytest Getting Started Guides
- [Pytest Get Started](https://docs.pytest.org/en/7.1.x/getting-started.html)
- [Pytest with Eric](https://pytest-with-eric.com/)
- [A Beginner's Guide to Unit Testing with Pytest](https://betterstack.com/community/guides/testing/pytest-guide/)
- [Effective Python Testing With Pytest](https://realpython.com/pytest-python-testing/)
- [A Complete Guide on How to Test Python Applications with Pytest](https://www.pythoncentral.io/a-complete-guide-on-how-to-test-python-applications-with-pytest/)
- [Testing in Python](https://testdriven.io/blog/testing-python/)

### Pytest Beyond Basics
- [Python Testing 101 (How To Decide What To Test)](https://pytest-with-eric.com/introduction/python-testing-strategy/)
- [Python Unit Testing Best Practices For Building Reliable Applications](https://pytest-with-eric.com/introduction/python-unit-testing-best-practices/)

### Pytest Corner Cases
- [Testing your python package as installed](https://blog.ganssle.io/articles/2019/08/test-as-installed.html)
- [What Is the Difference Between Invoking `pytest` and `python -m pytest`](https://jugmac00.github.io/til/what-is-the-difference-between-invoking-pytest-and-python-m-pytest/)

### Monkeypatch and Mocking
- [Monkeypatching/mocking modules and environments](https://docs.pytest.org/en/6.2.x/monkeypatch.html)
- [How to monkeypatch/mock modules and environments](https://docs.pytest.org/en/7.1.x/how-to/monkeypatch.html)
- [The Ultimate Guide To Using Pytest Monkeypatch with 2 Code Examples](https://pytest-with-eric.com/mocking/pytest-monkeypatch/)
- [Mocks and Monkeypatching in Python](https://semaphoreci.com/community/tutorials/mocks-and-monkeypatching-in-python)
- [What is monkey patching?](https://stackoverflow.com/a/5626250)
