const path = require("path")

module.exports = {
  mode: "development",
  entry: path.resolve(__dirname, "index.js"),
  output: {
    path: __dirname,
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
    extensions: [".js", ".jsx"]
  }
}
