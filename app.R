# remotes::install_github("jrosell/ambhtmx", force = TRUE)
library(ambhtmx)

what_file <- "output/what.txt"
invisible(!dir.exists("output") &&  dir.create("output"))

page_title <- "ambhtmx artyom example"

head_tags <- htmltools::tagList(      
  tags$link(href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css", rel = "stylesheet", integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH",  crossorigin="anonymous"),
  tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js", integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz", crossorigin="anonymous"),
  htmltools::HTML('<script src="https://cdn.jsdelivr.net/gh/gnat/surreal@main/surreal.js"></script><script src="https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js"></script>'),
  htmltools::HTML('<script src="https://cdn.jsdelivr.net/gh/sdkcarlos/artyom.js@master/build/artyom.window.min.js"></script>'),
  htmltools::HTML(' <script>window.artyom = window.artyom || new Artyom();</script>')  
)

amb_artyom <- \(lang, redirect_sel, accepts_name) {
  ambhtmx::script_tpl(
    lang = lang,
    redirect_sel = redirect_sel,
    accepts_name = accepts_name,
    raw_content = htmlwidgets::JS('
      artyom.addCommands([{
        description:"It will save the text it recognizes.",
        indexes: ["*"],
        smart: true,
        action : function(i, wildcard, sentence){
          if(wildcard.includes("stop listening")){
            document.querySelector(\'[name="{accepts_name}"]\').checked = false;
            console.log("Stop listening checked")
          }
          if(document.querySelector(\'[name="{accepts_name}"]\').checked) {
            var sel = document.querySelector("#listening-text");
            sel.innerHTML = sel.innerHTML + "\\n" + wildcard;
            var xhr = new XMLHttpRequest()
            var formData = new FormData();
            formData.append("what", wildcard);
            xhr.open("POST", "/listen")
            // xhr.setRequestHeader("Content-Type", "multipart/form-data")
            // xhr.setRequestHeader("Accept", "multipart/form-data")
            xhr.send(formData)
          }
          if(wildcard.includes("start listening")){
            document.querySelector(\'[name="{accepts_name}"]\').checked = true;
            console.log("Start listening checked")
          }
        }
      }]);
      artyom.redirectRecognizedTextOutput(function(text, isFinal){
          var sel = document.querySelector("{redirect_sel}")
          if(isFinal){
              sel.innerHTML = "";
          }else{
              sel.innerHTML = text;
          }
      });
      document.addEventListener("DOMContentLoaded", function(){            
          artyom.initialize({
              lang: "{lang}",
              debug: true,
              continuous: true,
              listen: true
          });
      });
    ')
  )
}

#' Starting the app and defining the routes
app <- ambhtmx(host = "0.0.0.0", port = "7860")$app$
  get("/", \(req, res){  
    div(
      id = "page", 
      style = "margin: 20px",
      h1("Speech recognition example with artyom.js"),
      p(strong("Say 'start listening' to start capturing what you say and 'stop listening' to stop.")),
      div(
        id = "main",
        div(
          style ="margin-bottom: 10px",
          div(p("Recognizing text: ", span(id = "recognized-text"))),
          div(label(
            "Captured text",
            tags$br(),
            HTML("<textarea rows=10 cols=40 id='listening-text'></textarea>")
          )),
          div(label(input(name="accepts", type = "checkbox", style = "margin-right: 10px", "listenining")))
        ),
        amb_artyom(
          lang = "en-US",
          redirect_sel = "#recognized-text",
          accepts_name = "accepts"
        )
      )
    ) |>
    send_page(res)
  })$
  post("/listen", \(req, res) {
    params <- parse_multipart(req)
    what <- params$what
    cat(glue("\nwhat: {what}\n\n"))
    write(what, file = what_file, append = TRUE)
    res$send(what)
  })

app$start(open = FALSE)





