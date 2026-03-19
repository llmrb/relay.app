const path = require("path")
const CopyPlugin = require("copy-webpack-plugin")

module.exports = {
  mode: "development",
  entry: path.resolve(__dirname, "js/index.js"),
  output: {
    path: path.resolve(__dirname, "..", "..", "public", "js"),
    filename: "realtalk.js",
    clean: false,
    publicPath: "/js/"
  },
  devtool: "source-map",
  watchOptions: {
    poll: 1000,
    aggregateTimeout: 200
  },
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
  devServer: {
    host: "0.0.0.0",
    port: 9293,
    allowedHosts: "all",
    static: [
      {
        directory: __dirname
      },
      {
        directory: path.resolve(__dirname, "..", "..", "public", "g"),
        publicPath: "/g"
      }
    ],
    client: {
      webSocketURL: {
        pathname: "/webpack"
      }
    },
    webSocketServer: {
      options: {
        path: "/webpack"
      }
    },
    proxy: [
      {
        context: ["/models"],
        target: "http://127.0.0.1:9292"
      },
      {
        context: ["/ws"],
        target: "http://127.0.0.1:9292",
        ws: true
      }
    ]
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        {
          from: path.resolve(__dirname, "*.html"),
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
