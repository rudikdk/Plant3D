valve_dialog : dialog {
  label = "Select Valve Code";
  : row {
    : text { label = "Valve Code:"; }
    : popup_list { key = "valveList"; width = 40; }
  }
  ok_cancel;
}
