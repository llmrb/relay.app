const path = require("path")
const CopyPlugin = require("copy-webpack-plugin")

module.exports = {
  mode: "development",
  entry: path.resolve(__dirname, "js/index.js"),
  output: {
    path: path.resolve(__dirname, "..", "..", "public", "js"),
    filename: "easytalk.js",
    clean: false
  },
  devtool: "source-map",
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-react"]
          }
        }
      },
      {
        test: /\.css$/,
        use: [
          "style-loader",
          "css-loader",
          "postcss-loader"
        ]
      }
    ]
  },
  resolve: {
    alias: {
      "~": __dirname
    },
    extensions: [".js", ".jsx"]
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        {
          from: path.resolve(__dirname, "html"),
          to: path.resolve(__dirname, "..", "..", "public")
        },
        {
          from: path.resolve(__dirname, "images"),
          to: path.resolve(__dirname, "..", "..", "public", "images")
        }
      ]
    })
  ]
}
