import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/size_config.dart';
import '../../../services/notes_service.dart';
import 'package:aplikasiku/models/model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _notes = await NotesService(
              baseUrl: "https://api-mobile.indoprosmamandiri.my.id")
          .fetchNotes(context);
    } catch (e) {
      _errorMessage = 'Gagal memuat catatan: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToNoteEditor({Note? note}) async {
    // Navigasi ke halaman penuh untuk tambah/edit catatan
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          note: note,
        ),
      ),
    );
    if (result == true) {
      await _fetchNotes();
    }
  }

  void _deleteNoteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Catatan',
            style: GoogleFonts.poppins(color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus catatan ini?',
            style: GoogleFonts.poppins(color: Colors.grey[700])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await NotesService(
                        baseUrl: "https://api-mobile.indoprosmamandiri.my.id")
                    .deleteNote(_notes[index].id!, context);
                setState(() => _notes.removeAt(index));
              } catch (e) {
                setState(() => _errorMessage = 'Gagal menghapus catatan: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sticky_note_2_outlined,
                size: 80, color: Colors.grey[300]),
            SizedBox(height: 20),
            Text('Belum ada catatan', style: GoogleFonts.poppins(fontSize: 18)),
            Text('Tekan tombol + untuk menambah catatan baru.',
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );

  Widget _buildNoteCard(int index) {
    final note = _notes[index];
    return Dismissible(
      key: Key('${note.id}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        _deleteNoteDialog(index);
        return false;
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () => _navigateToNoteEditor(note: note),
          title: Text(note.judul ?? note.content ?? '-',
              style: GoogleFonts.poppins()),
          subtitle: Text(
            note.tanggalCatatan != null
                ? DateFormat('dd MMM yyyy', 'id_ID')
                    .format(DateTime.parse(note.tanggalCatatan!))
                : '-',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteNoteDialog(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white, // panah kembali berwarna putih
          ),
          title: Text(
            'Catatan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!, style: GoogleFonts.poppins()))
              : _notes.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildNoteCard(index),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNoteEditor(),
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Halaman penuh untuk tambah/edit catatan
class NoteEditorPage extends StatefulWidget {
  final Note? note;
  const NoteEditorPage({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.judul ?? '');
    _noteController = TextEditingController(text: widget.note?.content ?? '');
    _selectedDate = widget.note?.tanggalCatatan != null
        ? DateTime.tryParse(widget.note!.tanggalCatatan!) ?? DateTime.now()
        : DateTime.now();
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      if (widget.note == null) {
        await NotesService(
                baseUrl: "https://api-mobile.indoprosmamandiri.my.id")
            .addNote(
          _noteController.text.trim(),
          _titleController.text.trim(),
          context,
          tanggalCatatan: _dateController.text,
        );
      } else {
        await NotesService(
                baseUrl: "https://api-mobile.indoprosmamandiri.my.id")
            .editNote(
          widget.note!.id!,
          _noteController.text.trim(),
          context,
          judul: _titleController.text.trim(),
          tanggalCatatan: _dateController.text,
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = widget.note == null
            ? 'Gagal menambah catatan: $e'
            : 'Gagal mengedit catatan: $e';
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 3,
          vertical: SizeConfig.blockSizeVertical * 1.5,
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller,
      DateTime selectedDate, Function(DateTime) onDatePicked) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: 'Tanggal Catatan',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDatePicked(picked);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.note == null ? 'Tambah Catatan' : 'Edit Catatan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: SizeConfig.blockSizeHorizontal * 4.2,
          ),
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField('Judul catatan', _titleController,
                      maxLines: 1),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  _buildTextField('Tulis catatan di sini...', _noteController,
                      maxLines: 6),
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  _buildDateField(_dateController, _selectedDate, (picked) {
                    setState(() {
                      _selectedDate = picked;
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    });
                  }),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
