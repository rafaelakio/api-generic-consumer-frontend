'use client';

import { useState, useCallback } from 'react';
import { Upload, X, File, Image, FileText, AlertCircle } from 'lucide-react';
import type { RequestFile } from '@/types';

interface FileUploadProps {
  files: RequestFile[];
  onFilesChange: (files: RequestFile[]) => void;
  maxFiles?: number;
  maxSize?: number;
  acceptedTypes?: string[];
}

const DEFAULT_MAX_SIZE = 10 * 1024 * 1024;
const DEFAULT_ACCEPTED_TYPES = ['*/*'];

export function FileUpload({
  files,
  onFilesChange,
  maxFiles = 10,
  maxSize = DEFAULT_MAX_SIZE,
  acceptedTypes = DEFAULT_ACCEPTED_TYPES,
}: FileUploadProps) {
  const [isDragOver, setIsDragOver] = useState(false);
  const [errors, setErrors] = useState<string[]>([]);

  const validateFile = useCallback((file: File): string | null => {
    if (file.size > maxSize) return `Arquivo "${file.name}" excede ${formatFileSize(maxSize)}`;
    if (acceptedTypes.length > 0 && !acceptedTypes.includes('*/*')) {
      const ok = acceptedTypes.some(t => t.endsWith('/*') ? file.type.startsWith(t.slice(0, -2)) : file.type === t);
      if (!ok) return `Arquivo "${file.name}" não é um tipo aceito`;
    }
    return null;
  }, [maxSize, acceptedTypes]);

  const processFiles = useCallback(async (fileList: FileList) => {
    const newFiles: RequestFile[] = [];
    const newErrors: string[] = [];
    if (files.length + fileList.length > maxFiles) {
      setErrors([`Máximo de ${maxFiles} arquivos permitidos`]);
      return;
    }
    for (let i = 0; i < fileList.length; i++) {
      const file = fileList[i];
      const err = validateFile(file);
      if (err) { newErrors.push(err); continue; }
      try {
        const content = await fileToBase64(file);
        newFiles.push({ id: `${Date.now()}-${i}`, name: file.name, size: file.size, type: file.type, content, fieldName: 'file' });
      } catch { newErrors.push(`Erro ao processar "${file.name}"`); }
    }
    setErrors(newErrors);
    if (newFiles.length > 0) onFilesChange([...files, ...newFiles]);
  }, [files, maxFiles, validateFile, onFilesChange]);

  const fileToBase64 = (file: File): Promise<string> =>
    new Promise((res, rej) => {
      const r = new FileReader();
      r.readAsDataURL(file);
      r.onload = () => res((r.result as string).split(',')[1]);
      r.onerror = rej;
    });

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault(); setIsDragOver(false);
    if (e.dataTransfer.files.length > 0) processFiles(e.dataTransfer.files);
  }, [processFiles]);

  const handleFileSelect = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.length) processFiles(e.target.files);
    e.target.value = '';
  }, [processFiles]);

  const getFileIcon = (type: string) => {
    if (type.startsWith('image/')) return <Image className="w-4 h-4 text-green-500" />;
    if (type.startsWith('text/')) return <FileText className="w-4 h-4 text-blue-500" />;
    return <File className="w-4 h-4 text-gray-500" />;
  };

  return (
    <div className="space-y-4">
      <div
        className={`border-2 border-dashed rounded-lg p-6 text-center transition-colors cursor-pointer ${isDragOver ? 'border-blue-400 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}`}
        onDragOver={(e) => { e.preventDefault(); setIsDragOver(true); }}
        onDragLeave={(e) => { e.preventDefault(); setIsDragOver(false); }}
        onDrop={handleDrop}
        onClick={() => document.getElementById('file-input')?.click()}
      >
        <input id="file-input" type="file" multiple accept={acceptedTypes.join(',')} onChange={handleFileSelect} className="hidden" />
        <Upload className="w-12 h-12 mx-auto mb-3 text-gray-400" />
        <p className="text-sm font-medium text-gray-700 mb-1">Arraste arquivos aqui ou clique para selecionar</p>
        <p className="text-xs text-gray-500">Máximo {maxFiles} arquivos • {formatFileSize(maxSize)} por arquivo</p>
      </div>
      {errors.map((e, i) => (
        <div key={i} className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
          <AlertCircle className="w-4 h-4 text-red-500" />
          <span className="text-sm text-red-700">{e}</span>
        </div>
      ))}
      {files.length > 0 && (
        <div className="space-y-2">
          <h4 className="text-sm font-medium text-gray-700">Arquivos ({files.length})</h4>
          {files.map((file) => (
            <div key={file.id} className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
              {getFileIcon(file.type)}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate">{file.name}</p>
                <p className="text-xs text-gray-500">{formatFileSize(file.size)} • {file.type}</p>
              </div>
              <button type="button" onClick={() => onFilesChange(files.filter(f => f.id !== file.id))} className="p-1 text-gray-400 hover:text-red-500">
                <X className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}
