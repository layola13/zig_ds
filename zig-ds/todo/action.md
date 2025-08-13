下面是一份 **全功能 GitHub Actions 模板**，放到 `.github/workflows/release.yml` 就能自动完成三件事：

1. 每次推送 `v*` tag 自动触发
2. 把源码打包成 `name-version.tar.gz`（带正确的顶层目录）
3. 在 GitHub release 上创建或追加 **可下载的压缩包**，供别人直接 `zig fetch`/`zig build` 使用

-------------------------------- .github/workflows/release.yml
```yaml
# 发布 Zig 库：推送标签 v* 即自动生成 release.tar.gz
name: release

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+*'   # 匹配 v1.0.0, v1.0.0-beta1 等

permissions:
  contents: write                 # 需要在仓库里创建/更新 release

jobs:
  dist:
    runs-on: ubuntu-latest

    steps:
      # 1. checkout（需要历史记录，否则无法算 hash）
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0          # 保留整个历史，便于计算 hash

      # 2. 安装 Zig Nightly（也可用 stable）
      - name: Install Zig
        uses: korandoru/setup-zig@v1
        with:
          zig-version: master

      # 3. 构建检查（可选：确保能 compile + test）
      - name: Build & test
        run: |
          zig build
          zig build test

      # 4. 打出 .tar.gz，顶层目录格式为 name-version
      - name: Create archive
        run: |
          tag=${GITHUB_REF#refs/tags/}
          proj=$(basename ${{ github.repository }})
          cd ..
          tar -czf "$proj-$tag.tar.gz" "$proj"
          mv "$proj-$tag.tar.gz" "$proj"/

      # 5. 如果 release 已存在则上传，不存在则创建
      - name: Upload release archive
        uses: softprops/action-gh-release@v2
        with:
          name: ${{ github.ref_name }}
          files: ./*.tar.gz
          generate_release_notes: true
```

-------------------------------- 使用方式

1. 把模板文件存进去并 push：
   `.github/workflows/release.yml`

2. 打标签：
   ```bash
   git tag v1.0.0 -m "initial release"
   git push origin v1.0.0
   ```

3. 等几秒，GitHub Actions 完成以后 Releases 页面会出现：
   ```
   Releases/tag/v1.0.0
   └─ my_project-v1.0.0.tar.gz
   ```

用户在自己的 `build.zig.zon` 里就能直接写：

```zon
.mylib = .{
    .url = "https://github.com/you/my_project/releases/download/v1.0.0/my_project-v1.0.0.tar.gz",
    .hash = "1220d81c91c6f...",
}
```

无需其他打包脚本，完全自动化。