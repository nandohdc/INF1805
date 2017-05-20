srv = net.createServer(net.TCP)

function receiver(sck, request)

  local vals = {
    QtdDevices = math.random(10),
    MaxTemp = math.random(100),
    MinTemp = math.random(20),
  }

  local buf = [[
<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="utf-8">
<meta name="description" content="INF1805 - Sistemas Reativos">
<meta name="keywords" content="React systems, Computer Engineering, INF1805">
<meta name="author" content="Felipe Vieira Côrtes e Fernando Homem da Costa">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>INF1805 - Project 3</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <h1 class="text-center">INF1805 - Projeto NodeMCU</h1>
      <h2 class="text-center">Biblioteca</h2>
    </div>
  </div>
  <hr>
  </hr>
  <div class="container">
    <div class="row">
        <table class="table" style = "margin-top: 10%">
          <thead>
            <tr>
              <th>Quantidade de dispositivos Ativos: </th>
              <th>Menor Temperatura (C): </th>
              <th>Maior Temperatura (C): </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>$QtdDevices</td>
              <td>$MinTemp</td>
              <td>$MaxTemp</td>
            </tr>
          </tbody>
        </table>
    </div>
  </div>
  <hr style="margin-top: 20%">
  <div class="row">
    <div class="text-center" >
      <div class="row" id="contact-me">
        <h4><strong>Authors</strong></h4>
        <div class="row">
          <p class="text-center">Felipe Vieira Cortes and Fernando Homem da Costa</p>
          <p class="text-center"><a href="https://github.com/nandohdc/INF1805/tree/master/Projects/T3%20-%20NodeMCU">GitHub</a></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
</body>
</html>
]]

  buf = string.gsub(buf, "$(%w+)", vals)
  sck:send(buf, function() print("respondeu") sck:close() end)
end

if srv then
  srv:listen(80,"10.80.70.116", function(conn)
      print("estabeleceu conexÃ£o")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")