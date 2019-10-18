"""
在请求阶段，调用视图之前，`Django`会按照`MIDDLEWARE_CLASSES`中定义的顺序自顶向下应用中间件。会用到两个钩子：

- process_request();
- process_view();

在响应阶段，调用视图之后，中间件会按照相反的顺序应用，自底向上。会用到三个钩子：

- process_exception();
- process_template_response();
- process_response()
"""