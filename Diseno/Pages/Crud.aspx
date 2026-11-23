<%@ Page Title="Usuario | Directorio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Crud.aspx.cs" Inherits="LaboratorioCrud.Web.Pages.FormularioUsuario" %>
<asp:Content ID="Cuerpo" ContentPlaceHolderID="MainContent" runat="server">
    <nav aria-label="Ruta de navegación" class="breadcrumb-line"><a href="Index.aspx">Directorio</a><span>/</span><a href="Index.aspx">Usuarios</a><span>/</span><strong><asp:Literal ID="RutaActual" runat="server" /></strong></nav>
    <div class="page-heading"><div><p class="eyebrow">DIRECTORIO DE USUARIOS</p><h1><asp:Literal ID="Titulo" runat="server" /></h1><p class="muted"><asp:Literal ID="Descripcion" runat="server" /></p></div><a href="Index.aspx" class="btn btn-secondary">Volver al listado</a></div>
    <asp:Label ID="Mensaje" runat="server" Visible="false" role="alert" />
    <asp:Panel ID="AvisoAnulacion" runat="server" Visible="false" CssClass="notice notice-warning"><strong>Confirma la anulación</strong><p>El usuario dejará de aparecer en el listado de activos. Su información y la fecha de esta acción se conservarán. Revisa los datos antes de confirmar.</p></asp:Panel>
    <asp:Panel ID="Formulario" runat="server" CssClass="form-layout">
        <section class="surface form-surface" aria-labelledby="datosPersonales"><div class="section-heading"><div><h2 id="datosPersonales">Información del usuario</h2><p class="muted">Los campos con asterisco son obligatorios.</p></div><span class="badge-soft"><asp:Literal ID="Identificador" runat="server" Text="NUEVO" /></span></div>
            <div class="form-grid">
                <div class="field"><asp:Label runat="server" AssociatedControlID="Nombre" Text="Nombre *" /><asp:TextBox ID="Nombre" runat="server" MaxLength="80" CssClass="form-control" autocomplete="given-name" placeholder="Ej. Ana" /></div>
                <div class="field"><asp:Label runat="server" AssociatedControlID="Apellido" Text="Apellido *" /><asp:TextBox ID="Apellido" runat="server" MaxLength="80" CssClass="form-control" autocomplete="family-name" placeholder="Ej. Torres" /></div>
                <div class="field span-two"><asp:Label runat="server" AssociatedControlID="Correo" Text="Correo electrónico *" /><asp:TextBox ID="Correo" runat="server" MaxLength="160" CssClass="form-control" TextMode="Email" autocomplete="email" placeholder="nombre@ejemplo.com" /><small>El correo identifica al usuario y no se puede repetir.</small></div>
                <div class="field"><asp:Label runat="server" AssociatedControlID="Telefono" Text="Teléfono" /><asp:TextBox ID="Telefono" runat="server" MaxLength="25" CssClass="form-control" TextMode="Phone" autocomplete="tel" placeholder="6000-0000" /></div>
                <div class="field"><asp:Label runat="server" AssociatedControlID="FechaNacimiento" Text="Fecha de nacimiento *" /><asp:TextBox ID="FechaNacimiento" runat="server" CssClass="form-control" TextMode="Date" /></div>
            </div>
            <div class="form-actions"><a href="Index.aspx" class="btn btn-secondary">Cancelar</a><asp:Button ID="Guardar" runat="server" Text="Crear usuario" CssClass="btn btn-primary" OnClick="Guardar_Click" /><asp:Button ID="ConfirmarAnulacion" runat="server" Text="Confirmar anulación" CssClass="btn btn-danger" OnClick="ConfirmarAnulacion_Click" Visible="false" /></div>
        </section>
        <aside class="record-aside"><h2>Sobre este registro</h2><p>La información se guarda en MySQL. Cada modificación conserva las fechas de auditoría.</p>
            <asp:Panel ID="Auditoria" runat="server" Visible="false"><dl class="audit-list"><dt>Estado</dt><dd><asp:Literal ID="Estado" runat="server" /></dd><dt>Fecha de registro</dt><dd><asp:Literal ID="FechaRegistro" runat="server" /></dd><dt>Última modificación</dt><dd><asp:Literal ID="FechaEdicion" runat="server" /></dd><dt>Fecha de anulación</dt><dd><asp:Literal ID="FechaAnulacion" runat="server" /></dd></dl></asp:Panel>
            <div class="aside-note"><strong>Un cambio a la vez</strong><p>Si alguien modifica este usuario mientras lo editas, vuelve a abrir el registro para trabajar con la información actualizada.</p></div>
        </aside>
    </asp:Panel>
</asp:Content>
