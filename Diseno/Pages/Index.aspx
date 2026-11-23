<%@ Page Title="Usuarios | Directorio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="LaboratorioCrud.Web.Pages.Indice" %>
<asp:Content ID="Cuerpo" ContentPlaceHolderID="MainContent" runat="server">
    <nav aria-label="Ruta de navegación" class="breadcrumb-line">Directorio <span>/</span> <strong>Usuarios</strong></nav>
    <div class="page-heading"><div><p class="eyebrow">TU DIRECTORIO, EN UN SOLO LUGAR</p><h1>Usuarios</h1><p class="muted">Consulta y mantén actualizada la información de tu equipo.</p></div>
        <a class="btn btn-primary" href="Crud.aspx?accion=crear"><span aria-hidden="true">+</span> Nuevo usuario</a>
    </div>
    <asp:Label ID="Mensaje" runat="server" Visible="false" role="status" />
    <section class="stats-row" aria-label="Resumen del listado">
        <div class="stat"><span class="stat-label">Usuarios visibles</span><strong><asp:Literal ID="Total" runat="server" Text="—" /></strong><span>En la consulta actual</span></div>
        <div class="stat"><span class="stat-label">Activos</span><strong><asp:Literal ID="Activos" runat="server" Text="—" /></strong><span><i class="dot green"></i> Disponibles para editar</span></div>
        <div class="stat"><span class="stat-label">Anulados</span><strong><asp:Literal ID="Anulados" runat="server" Text="—" /></strong><span>Con historial conservado</span></div>
    </section>
    <section class="surface" aria-labelledby="tituloListado">
        <div class="section-heading"><div><h2 id="tituloListado">Directorio de usuarios</h2><p class="muted">Selecciona un registro para ver su información o administrarlo.</p></div><span class="badge-soft">USUARIOS</span></div>
        <div class="toolbar">
            <div class="search-field"><asp:Label runat="server" AssociatedControlID="Busqueda" CssClass="visually-hidden" Text="Buscar por nombre o correo" /><asp:TextBox ID="Busqueda" runat="server" MaxLength="160" CssClass="form-control" placeholder="Buscar por nombre o correo…" /></div>
            <asp:Button ID="Buscar" runat="server" Text="Buscar" CssClass="btn btn-secondary" OnClick="Buscar_Click" CausesValidation="false" />
            <asp:Button ID="Limpiar" runat="server" Text="Limpiar" CssClass="btn btn-ghost" OnClick="Limpiar_Click" CausesValidation="false" />
            <label class="check-filter"><asp:CheckBox ID="IncluirAnulados" runat="server" AutoPostBack="true" OnCheckedChanged="Filtro_Changed" /> Incluir anulados</label>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="Usuarios" runat="server" AutoGenerateColumns="false" CssClass="table user-table" GridLines="None" DataKeyNames="IdUsuario" UseAccessibleHeader="true" ShowHeaderWhenEmpty="true" EmptyDataText="No hay usuarios que coincidan con tu búsqueda." OnRowCommand="Usuarios_RowCommand">
                <Columns>
                    <asp:BoundField DataField="IdUsuario" HeaderText="ID" />
                    <asp:TemplateField HeaderText="Usuario"><ItemTemplate><div class="person-cell"><span class="person-avatar" aria-hidden="true"><%#: Eval("Nombre").ToString().Substring(0,1) %></span><div><strong><%#: Eval("NombreCompleto") %></strong><span><%#: Eval("Correo") %></span></div></div></ItemTemplate></asp:TemplateField>
                    <asp:BoundField DataField="Telefono" HeaderText="Teléfono" />
                    <asp:TemplateField HeaderText="Estado"><ItemTemplate><span class='<%# (bool)Eval("Activo") ? "status status-active" : "status status-inactive" %>'><%#: Eval("Estado") %></span></ItemTemplate></asp:TemplateField>
                    <asp:BoundField DataField="FechaDeInsercion" HeaderText="Registro" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:TemplateField HeaderText="Acciones"><ItemTemplate><div class="row-actions">
                        <asp:Button ID="Ver" runat="server" Text="Ver" CssClass="row-action" CommandName="ConsultarUsuario" CommandArgument='<%# Eval("IdUsuario") %>' CausesValidation="false" />
                        <asp:Button ID="Editar" runat="server" Text="Editar" CssClass="row-action" CommandName="EditarUsuario" CommandArgument='<%# Eval("IdUsuario") %>' Visible='<%# (bool)Eval("Activo") %>' CausesValidation="false" />
                        <asp:Button ID="Eliminar" runat="server" Text="Anular" CssClass="row-action danger" CommandName="AnularUsuario" CommandArgument='<%# Eval("IdUsuario") %>' Visible='<%# (bool)Eval("Activo") %>' CausesValidation="false" />
                    </div></ItemTemplate></asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <div class="table-footer"><asp:Literal ID="Conteo" runat="server" Text="Conecta la base de datos para consultar los registros." /><span>La anulación conserva el historial del usuario.</span></div>
    </section>
</asp:Content>
