const path = require("path")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

const root = __dirname
const production = process.env.NODE_ENV === "production"

module.exports = {
  mode: production ? "production" : "development",
  entry: path.resolve(root, "js/application.js"),
  output: {
    path: path.resolve(root, "..", "..", "..", "public", "js"),
    filename: "application.js",
    clean: false,
    publicPath: "/js/"
  },
  devtool: production ? false : "source-map",
  watchOptions: {
    poll: 1000,
    aggregateTimeout: 200
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          "postcss-loader"
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "../stylesheets/application.css"
    })
  ]
}
