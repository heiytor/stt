import koa from "koa";
import koaStatic from "koa-static";

let app = new koa();

app.use(koaStatic("static/"));
app.use(koaStatic("bundled/"));

app.use((ctx, next) => {
  if (ctx.path === "/health" && ctx.method === "GET") {
    ctx.status = 200;
    return;
  }
  return next();
});

app.listen(8080, () => console.info("OpenAPI server started."));
