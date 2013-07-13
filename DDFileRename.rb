include Java

import java.awt.BorderLayout
import java.awt.GridLayout
import java.awt.datatransfer.DataFlavor
import java.awt.datatransfer.Transferable
import java.awt.dnd.DnDConstants
import java.awt.dnd.DropTarget
import java.awt.dnd.DropTargetListener
import java.awt.event.ActionListener
import javax.swing.JButton
import javax.swing.JCheckBox
import javax.swing.JFrame
import javax.swing.JPanel
import javax.swing.JScrollPane
import javax.swing.JTextArea
import javax.swing.JTextField

class DDFileRename
  include ActionListener
  include DropTargetListener
  include java.lang.Runnable

  COLUMN = 30

  def initialize
    @files = []
    @fileArea = nil
    @findText = nil
    @replaceText = nil
    @regexCheck = nil
  end

  def createAndShowGui
    frame = JFrame.new("DDFileRename")
    frame.setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    frame.getContentPane.setLayout(BorderLayout.new)
    filePane = createFileArea
    frame.getContentPane.add(filePane, BorderLayout::CENTER)
    pane = createInputPane
    frame.getContentPane.add(pane, BorderLayout::SOUTH)
    frame.pack
    frame.setVisible(true)
  end

  def createFileArea
    @fileArea = JTextArea.new(10, COLUMN)
    @fileArea.setEditable(false)
    DropTarget.new(@fileArea, self)
    return JScrollPane.new(@fileArea)
  end

  def createInputPane
    pane = JPanel.new
    pane.setLayout(GridLayout.new(0, 1))
    @regexCheck = JCheckBox.new("Regular Expression")
    pane.add(@regexCheck)
    @findText = JTextField.new("", COLUMN)
    pane.add(@findText)
    @replaceText = JTextField.new("", COLUMN)
    pane.add(@replaceText)
    button = JButton.new("Replace")
    button.addActionListener(self)
    pane.add(button)
    return pane
  end

  def drop(e)
    begin
      transfer = e.getTransferable
      if !transfer.isDataFlavorSupported(DataFlavor::javaFileListFlavor)
        return
      end
      e.acceptDrop(DnDConstants::ACTION_COPY_OR_MOVE)
      @files = transfer.getTransferData(DataFlavor::javaFileListFlavor)
      showFiles
    rescue
      $stderr.puts($!.message)
    end
  end

  def showFiles
    buf = @files.map{|f| f.getName}.join("\n")
    @fileArea.setText(buf)
  end

  def dragEnter(dtde)
  end

  def dragOver(dtde)
  end

  def dropActionChanged(dtde)
  end

  def dragExit(dte)
  end

  def actionPerformed(ae)
    @files = replaceAll
    showFiles
  end

  def replaceAll
    newfiles = []
    @files.each do |file|
      newfile = replace(file, getPattern, @replaceText.getText)
      newfiles << newfile
    end
    return newfiles
  end

  def replace(file, pattern, replacement)
    newname = file.getName.sub(pattern, replacement)
    newfile = java.io.File.new(file.getParent, newname)
    return file.renameTo(newfile) ? newfile : file
  end

  def getPattern
    pat = @findText.getText
    return @regexCheck.isSelected ? Regexp.compile(pat) : pat
  end

  def run
    createAndShowGui
  end
end

javax.swing.SwingUtilities.invokeLater(DDFileRename.new)
